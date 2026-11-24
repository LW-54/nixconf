// Mirrors Nixconf/Data/AttrExpr.lean (Layer 0 Shared Boolean Set-Algebra Lattice)

#[derive(Clone, Debug)]
pub enum AttrExpr {
    Atom(String),
    Union(Box<AttrExpr>, Box<AttrExpr>),
    Inter(Box<AttrExpr>, Box<AttrExpr>),
    Diff(Box<AttrExpr>, Box<AttrExpr>),
    Compl(Box<AttrExpr>),
    Any,
    NoneExpr,
}

impl AttrExpr {
    pub fn eval(&self, tags: &[String]) -> bool {
        match self {
            AttrExpr::Atom(t) => tags.iter().any(|x| x == t),
            AttrExpr::Union(a, b) => a.eval(tags) || b.eval(tags),
            AttrExpr::Inter(a, b) => a.eval(tags) && b.eval(tags),
            AttrExpr::Diff(a, b) => a.eval(tags) && !b.eval(tags),
            AttrExpr::Compl(i) => !i.eval(tags),
            AttrExpr::Any => true,
            AttrExpr::NoneExpr => false,
        }
    }
}
