Require Export TopologicalSpaces NeighborhoodBases.
From ZornsLemma Require Export CountableTypes.
From ZornsLemma Require Import DecidableDec EnsemblesSpec EnsemblesTactics InfiniteTypes.
From Coq Require Import ClassicalChoice Program.Subset.

Global Set Asymmetric Patterns.

Definition first_countable (X:TopologicalSpace) : Prop :=
  forall x:point_set X, exists NBx:Family X,
    neighborhood_basis NBx x /\ Countable NBx.

Lemma first_countable_open_neighborhood_bases:
  forall X:TopologicalSpace, first_countable X ->
    forall x:point_set X, exists NBx:Family X,
      open_neighborhood_basis NBx x /\ Countable NBx.
Proof.
intros.
destruct (H x) as [NBx [? ?]].
exists (@Im (Ensemble X) (Ensemble X) NBx (@interior X)).
split.
- constructor; intros.
  + destruct H2.
    split; rewrite H3.
    * apply interior_open.
    * now apply neighborhood_interior, H0.
  + destruct H0.
    destruct (neighborhood_basis_cond U) as [N].
    * now apply open_neighborhood_is_neighborhood.
    * destruct H0.
      exists (interior N).
      split.
      ** now exists N.
      ** pose proof (interior_deflationary N).
         auto with sets.
- now apply countable_img.
Qed.

Require Export Nets.

Lemma first_countable_sequence_closure:
  forall (X:TopologicalSpace) (S:Ensemble X) (x:point_set X),
  first_countable X -> In (closure S) x ->
  exists y:Net nat_DS X, (forall n:nat, In S (y n)) /\
                         net_limit y x.
Proof.
intros.
destruct (first_countable_open_neighborhood_bases _ H x) as [NB []].
destruct H2 as [g].
pose (U (n:nat) := IndexedIntersection
  (fun x: {x:{x:Ensemble X | In NB x} | (g x < n)%nat} =>
     proj1_sig (proj1_sig x))).
assert (forall n:nat, open (U n)).
{ intros.
  apply open_finite_indexed_intersection.
- apply inj_finite with _ (fun x:{x:{x:Ensemble X | In NB x}
                             | (g x < n)%nat} =>
    exist (fun m:nat => (m<n)%nat) (g (proj1_sig x)) (proj2_sig x)).
  + apply finite_nat_initial_segment.
  + intros [[x0 P] p] [[y0 Q] q] ?.
    simpl in H3.
    apply subset_eq, subset_eq. simpl.
    injection H3; intros.
    apply H2 in H4.
    now injection H4.
  + intros; apply classic.
- intros.
  destruct a as [[x0]].
  now apply H1.
}
destruct (choice (fun (n:nat) (x:point_set X) => In (U n) x /\
                                                 In S x)) as [y].
- intros n.
  destruct (closure_impl_meets_every_open_neighborhood _ _ _ H0 (U n))
    as [y]; trivial.
  + constructor; trivial.
    destruct a as [[x0]].
    simpl.
    now apply H1.
  + exists y.
    destruct H4.
    now split.
- exists y.
  split.
  + apply H4.
  + red; intros V ? ?.
    destruct H1.
    destruct (open_neighborhood_basis_cond V) as [W []].
    * now split.
    * pose (a := (exist _ W H1 : {x:Ensemble X|In NB x})).
      exists (Datatypes.S (g a)).
      intros.
      simpl in j.
      simpl in H8.
      apply H7.
      assert (Included (U j) W).
    { red; intros.
      destruct H9.
      exact (H9 (exist _ a H8)). }
      apply H9, H4.
Qed.

Inductive separable (X:TopologicalSpace) : Prop :=
  | intro_dense_ctbl: forall S:Ensemble X,
    Countable S -> dense S -> separable X.

Definition Lindelof (X:TopologicalSpace) : Prop :=
  forall cover:Family X,
    (forall U:Ensemble X,
       In cover U -> open U) ->
    FamilyUnion cover = Full_set ->
  exists subcover:Family X, Included subcover cover /\
     Countable subcover /\ FamilyUnion subcover = Full_set.

Inductive second_countable (X:TopologicalSpace) : Prop :=
  | intro_ctbl_basis: forall B:Family X,
    open_basis B -> Countable B -> second_countable X.

Lemma second_countable_impl_first_countable:
  forall X:TopologicalSpace, second_countable X -> first_countable X.
Proof.
intros.
destruct H.
red; intros.
exists [ U:Ensemble X | In B U /\ In U x ]; split.
- apply open_neighborhood_basis_is_neighborhood_basis.
  apply open_basis_to_open_neighborhood_basis; trivial.
- apply countable_downward_closed with B; trivial.
  red; intros.
  now destruct H1 as [[? ?]].
Qed.

Lemma second_countable_impl_separable:
  forall X:TopologicalSpace, second_countable X -> separable X.
Proof.
intros.
destruct H.
destruct (choice (fun (U:{U:Ensemble X | In B U /\ Inhabited U})
  (x:point_set X) => In (proj1_sig U) x)) as [choice_fun].
- intros.
  destruct x as [U [? ?]].
  simpl.
  destruct i0.
  now exists x.
- exists (Im Full_set choice_fun).
  + apply countable_img.
    red.
    match goal with |- CountableT ?S =>
      pose (g := fun (x:S) =>
        match x return {U:Ensemble X | In B U} with
        | exist (exist U (conj i _)) _ => exist _ U i
        end)
    end.
    apply inj_countable with g; trivial.
    red; intros x y H2.
    unfold g in H2.
    destruct x as [[U [? ?]]].
    destruct y as [[V [? ?]]].
    apply ProofIrrelevance.ProofIrrelevanceTheory.subset_eq_compat.
    apply ProofIrrelevance.ProofIrrelevanceTheory.subset_eq_compat.
    now injection H2.
  + apply meets_every_nonempty_open_impl_dense.
    intros.
    destruct H3, H.
    destruct (open_basis_cover x U) as [V [? [? ?]]]; trivial.
    assert (In B V /\ Inhabited V).
    * split; trivial.
      exists x; trivial.
    * exists (choice_fun (exist _ V H6)).
      constructor.
      ** (* apply H4. *)
         pose proof (H1 (exist _ V H6)).
         simpl in H7.
         (* assumption. *)
         exists (exist (fun U0:Ensemble X => In B U0 /\ Inhabited U0) V H6).
         *** constructor.
         *** reflexivity.
      ** apply H4.
         now pose proof (H1 (exist _ V H6)).
Qed.

Lemma second_countable_impl_Lindelof:
  forall X:TopologicalSpace, second_countable X -> Lindelof X.
Proof.
intros.
destruct H.
red; intros.
pose (basis_elts_contained_in_cover_elt :=
  [ U:Ensemble X | In B U /\ Inhabited U /\
    exists V:Ensemble X, In cover V /\ Included U V ]).
destruct (choice (fun (U:{U | In basis_elts_contained_in_cover_elt U})
  (V:Ensemble X) => In cover V /\ Included (proj1_sig U) V))
  as [choice_fun].
- intros.
  destruct x.
  simpl.
  now destruct i as [[? [? ?]]].
- exists (Im Full_set choice_fun).
  repeat split.
  + red; intros.
    destruct H4.
    destruct (H3 x).
    rewrite H5; assumption.
  + apply countable_img, countable_type_ensemble.
    apply countable_downward_closed with B; trivial.
    red; intros.
    now destruct H4 as [[]].
  + extensionality_ensembles.
    { constructor. }
    assert (In (FamilyUnion cover) x).
    { rewrite H2. constructor. }
    destruct H4, H.
    destruct (open_basis_cover x S) as [V]; trivial.
    { now apply H1. }
    destruct H as [? [? ?]].
    assert (In basis_elts_contained_in_cover_elt V).
    { constructor.
      repeat split; trivial.
      - now exists x.
      - exists S; now split.
    }
    exists (choice_fun (exist _ V H8)).
    * exists (exist _ V H8); auto with sets.
    * pose proof (H3 (exist _ V H8)).
      destruct H9.
      now apply H10.
Qed.
