//! port: engine/lisp/ecs.lisp — entity handles and per-kind component stores.
//!
//! A handle is `slot + 256 × generation` exactly as the Lisp's (the B line prints handles raw: `fighter-opp` 257 is slot 1,
//! generation 1). Spawn takes the first free slot; destroy bumps the slot's generation (masked to 20 bits) and shrinks `top`.
//! `Entities` holds the shared `used` / `generation` / `top`; each `Store<T>` keeps its components sorted by slot, tagged with
//! the handle they were attached to, so `get` of a stale handle is `None` (the owner clears every store on destroy).
//!
//! `do-entities` (slot order, `top` read once at loop start, `used` and the component re-checked at each slot) is an index loop:
//! ```ignore
//! let top = m.ents.top;
//! for s in 0..top { let Some(e) = m.ents.at(s) else { continue }; if let Some(h) = m.hazards.get(e) { … } }
//! ```
//! A spawn into a freed slot above the cursor is visited in this pass; one at or above the old `top` is not; an entity destroyed
//! ahead of the cursor is skipped.
use crate::consts::MAX_ENTITIES;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Entity(pub u32);

impl Entity {
    /// Lisp NIL in a handle slot (`*p1*` before a match): never alive (its generation is above the 20-bit mask).
    pub const NIL: Entity = Entity(u32::MAX);
    pub fn slot(self) -> usize {
        (self.0 as usize) & (MAX_ENTITIES - 1)
    }
    pub fn generation(self) -> u32 {
        self.0 >> 8
    }
}

#[derive(Clone, Debug)]
pub struct Entities {
    generation: [u32; MAX_ENTITIES],
    used: [bool; MAX_ENTITIES],
    /// One past the highest slot in use (`*top*`).
    pub top: usize,
}

impl Default for Entities {
    fn default() -> Self {
        Entities {
            generation: [0; MAX_ENTITIES],
            used: [false; MAX_ENTITIES],
            top: 0,
        }
    }
}

impl Entities {
    /// port: entity-alive-p.
    pub fn alive(&self, e: Entity) -> bool {
        let s = e.slot();
        self.used[s] && self.generation[s] == e.generation()
    }
    /// The live entity at slot S (`do-entities`' per-slot check), if any.
    pub fn at(&self, s: usize) -> Option<Entity> {
        self.used[s].then(|| Entity((s + MAX_ENTITIES * self.generation[s] as usize) as u32))
    }
    /// port: spawn-entity (the slot only: the caller attaches components).
    pub fn spawn(&mut self) -> Entity {
        let s = self
            .used
            .iter()
            .position(|u| !u)
            .unwrap_or_else(|| panic!("ecs: more than {MAX_ENTITIES} entities"));
        self.used[s] = true;
        self.top = self.top.max(s + 1);
        self.at(s).unwrap()
    }
    /// port: destroy-entity's slot bookkeeping. True when E was alive (the caller then clears its components).
    pub fn kill(&mut self, e: Entity) -> bool {
        if !self.alive(e) {
            return false;
        }
        let s = e.slot();
        self.used[s] = false;
        self.generation[s] = (self.generation[s] + 1) & 0xFFFFF;
        while self.top > 0 && !self.used[self.top - 1] {
            self.top -= 1;
        }
        true
    }
}

/// One component kind: (handle, component), sorted by slot. Small (a few entities live), so clones stay cheap.
#[derive(Clone, Debug)]
pub struct Store<T> {
    items: Vec<(Entity, T)>,
}

impl<T> Default for Store<T> {
    fn default() -> Self {
        Store { items: Vec::with_capacity(MAX_ENTITIES) } // (never grows in a step: the 0 B / step rule)
    }
}

impl<T> Store<T> {
    fn find(&self, s: usize) -> Result<usize, usize> {
        self.items.binary_search_by_key(&s, |(e, _)| e.slot())
    }
    /// port: add-component (replaces one of the same kind). E must be alive (the caller's check, as the Lisp's).
    pub fn insert(&mut self, e: Entity, c: T) {
        match self.find(e.slot()) {
            Ok(i) => self.items[i] = (e, c),
            Err(i) => self.items.insert(i, (e, c)),
        }
    }
    /// port: remove-component (a stale handle removes nothing).
    pub fn remove(&mut self, e: Entity) {
        self.take(e);
    }
    /// REMOVE, giving the component back.
    pub fn take(&mut self, e: Entity) -> Option<T> {
        match self.find(e.slot()) {
            Ok(i) if self.items[i].0 == e => Some(self.items.remove(i).1),
            _ => None,
        }
    }
    /// The component getter `(name e)`: None for an absent component or a stale handle.
    pub fn get(&self, e: Entity) -> Option<&T> {
        self.find(e.slot())
            .ok()
            .filter(|&i| self.items[i].0 == e)
            .map(|i| &self.items[i].1)
    }
    pub fn get_mut(&mut self, e: Entity) -> Option<&mut T> {
        match self.find(e.slot()) {
            Ok(i) if self.items[i].0 == e => Some(&mut self.items[i].1),
            _ => None,
        }
    }
    pub fn has(&self, e: Entity) -> bool {
        self.get(e).is_some()
    }
    /// In slot order (`do-entities` without mutation).
    pub fn iter(&self) -> impl Iterator<Item = (Entity, &T)> {
        self.items.iter().map(|(e, c)| (*e, c))
    }
    pub fn len(&self) -> usize {
        self.items.len()
    }
    pub fn is_empty(&self) -> bool {
        self.items.is_empty()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// tests/ecs-test.lisp's entity checks (events are not ported: `emit` only feeds the look side).
    #[test]
    fn ecs_test_lisp() {
        let mut ents = Entities::default();
        let (mut pos, mut tag) = (Store::<i64>::default(), Store::<()>::default());
        let a = ents.spawn();
        pos.insert(a, 1);
        tag.insert(a, ());
        let b = ents.spawn();
        pos.insert(b, 2);
        assert!(ents.alive(a) && pos.get(a) == Some(&1) && tag.has(a) && !tag.has(b));
        let both: Vec<i64> = (0..ents.top)
            .filter_map(|s| ents.at(s))
            .filter(|&e| tag.has(e))
            .map(|e| *pos.get(e).unwrap())
            .collect();
        assert_eq!(both, [1]);
        assert_eq!(pos.iter().map(|(e, _)| e).collect::<Vec<_>>(), [a, b]); // slot order
        tag.remove(a);
        assert!(!tag.has(a));
        assert!(ents.kill(a));
        pos.remove(a);
        assert!(!ents.alive(a) && pos.get(a).is_none());
        let c = ents.spawn(); // reuses a's slot, new generation
        pos.insert(c, 3);
        assert!(c.slot() == a.slot() && c != a && pos.get(a).is_none() && pos.get(c) == Some(&3));
        assert!(!ents.alive(Entity::NIL));
        for s in 0..ents.top {
            if let Some(e) = ents.at(s) {
                ents.kill(e);
            }
        }
        assert_eq!(ents.top, 0);
    }
}
