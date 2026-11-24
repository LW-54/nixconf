//! Shared Boolean Set-Algebra Lattice (`AttrExpr`) mirroring `Aky/Data/AttrExpr.lean`.
//!
//! One algebraic primitive powers Cedar/Biscuit `L3+` authorization policies,
//! `B3` partitioned routing selectors, and `S2+` open composable state traits.

use serde::{Deserialize, Serialize};

/// Boolean set-algebra predicate over string attribute tags.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "lowercase")]
pub enum AttrExpr {
    /// Matches iff `tag` is present in the entity's attribute set.
    Atom {
        /// Exact tag string to match.
        tag: String,
    },
    /// Logical disjunction (set union `∪`).
    Union {
        /// Left operand.
        left: Box<Self>,
        /// Right operand.
        right: Box<Self>,
    },
    /// Logical conjunction (set intersection `∩`).
    Inter {
        /// Left operand.
        left: Box<Self>,
        /// Right operand.
        right: Box<Self>,
    },
    /// Set difference (`left \ right`).
    Diff {
        /// Included operand.
        left: Box<Self>,
        /// Excluded operand.
        right: Box<Self>,
    },
    /// Logical complement (`¬ inner`).
    Compl {
        /// Negated operand.
        inner: Box<Self>,
    },
    /// Universal predicate matching every tag set.
    Any,
    /// Empty predicate matching no tag set.
    #[serde(rename = "none")]
    NoneExpr,
}

impl AttrExpr {
    /// Constructs an atomic tag predicate.
    #[must_use]
    pub fn atom(tag: impl Into<String>) -> Self {
        Self::Atom { tag: tag.into() }
    }

    /// Constructs a union (`∪`) predicate.
    #[must_use]
    pub fn union(left: Self, right: Self) -> Self {
        Self::Union {
            left: Box::new(left),
            right: Box::new(right),
        }
    }

    /// Constructs an intersection (`∩`) predicate.
    #[must_use]
    pub fn inter(left: Self, right: Self) -> Self {
        Self::Inter {
            left: Box::new(left),
            right: Box::new(right),
        }
    }

    /// Constructs a set-difference (`\`) predicate.
    #[must_use]
    pub fn diff(left: Self, right: Self) -> Self {
        Self::Diff {
            left: Box::new(left),
            right: Box::new(right),
        }
    }

    /// Constructs a complement (`¬`) predicate.
    #[must_use]
    pub fn compl(inner: Self) -> Self {
        Self::Compl {
            inner: Box::new(inner),
        }
    }

    /// Evaluates this Boolean lattice expression against a slice of tags.
    #[must_use]
    pub fn eval(&self, tags: &[String]) -> bool {
        match self {
            Self::Atom { tag } => tags.iter().any(|t| t == tag),
            Self::Union { left, right } => left.eval(tags) || right.eval(tags),
            Self::Inter { left, right } => left.eval(tags) && right.eval(tags),
            Self::Diff { left, right } => left.eval(tags) && !right.eval(tags),
            Self::Compl { inner } => !inner.eval(tags),
            Self::Any => true,
            Self::NoneExpr => false,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::AttrExpr;

    #[test]
    fn diff_excludes_right_operand() {
        let expr = AttrExpr::diff(
            AttrExpr::atom("survives-reboot"),
            AttrExpr::atom("reconstructible"),
        );
        assert!(expr.eval(&["survives-reboot".to_string()]));
        assert!(!expr.eval(&["survives-reboot".to_string(), "reconstructible".to_string()]));
    }
}
