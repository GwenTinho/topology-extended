From ZornsLemma Require Export DirectedSets.
From Topology Require Export TopologicalSpaces InteriorsClosures Continuity.

Set Asymmetric Patterns.

Section Net.

Variable I:DirectedSet.
Variable X:TopologicalSpace.

Definition Net := DS_set I -> X.

Definition net_limit (x:Net) (x0:X) : Prop :=
  forall U:Ensemble X, open U -> In U x0 ->
  for large i:DS_set I, In U (x i).

Definition net_cluster_point (x:Net) (x0:X) : Prop :=
  forall U:Ensemble X, open U -> In U x0 ->
  exists arbitrarily large i:DS_set I, In U (x i).

Lemma net_limit_is_cluster_point: forall (x:Net) (x0:X),
  net_limit x x0 -> net_cluster_point x x0.
Proof.
intros.
red. intros.
red. intros.
destruct (H U H0 H1).
destruct (DS_join_cond i x1).
destruct H3.
exists x2.
split; trivial.
now apply H2.
Qed.

Lemma net_limit_in_closure: forall (S:Ensemble X)
  (x:Net) (x0:X),
  (exists arbitrarily large i:DS_set I, In S (x i)) ->
  net_limit x x0 -> In (closure S) x0.
Proof.
intros.
apply NNPP.
intro.
pose proof (H0 (Complement (closure S))).
match type of H2 with | ?A -> ?B -> ?C => assert (C) end.
{ apply H2; trivial.
  apply closure_closed. }
destruct H3, (H x1).
contradiction (H3 x2);
  [ | apply closure_inflationary ];
  tauto.
Qed.

Lemma net_cluster_point_in_closure: forall (S:Ensemble X)
  (x:Net) (x0:X),
  (for large i:DS_set I, In S (x i)) ->
  net_cluster_point x x0 -> In (closure S) x0.
Proof.
intros.
apply NNPP.
intro.
pose proof (H0 (Complement (closure S))).
match type of H2 with | ?A -> ?B -> ?C => assert (C) end.
{ apply H2; trivial.
  apply closure_closed. }
destruct H, (H3 x1), H4.
contradiction H5.
apply closure_inflationary.
now apply H.
Qed.

End Net.

Arguments net_limit {I} {X}.
Arguments net_cluster_point {I} {X}.
Arguments net_limit_is_cluster_point {I} {X}.
Arguments net_limit_in_closure {I} {X}.
Arguments net_cluster_point_in_closure {I} {X}.

Section neighborhood_net.

Variable X:TopologicalSpace.
Variable x:X.

Inductive neighborhood_net_DS_set : Type :=
  | intro_neighborhood_net_DS :
    forall (U:Ensemble X) (y:X),
    open U -> In U x -> In U y -> neighborhood_net_DS_set.

Definition neighborhood_net_DS_ord
  (Uy Vz:neighborhood_net_DS_set) : Prop :=
  match Uy, Vz with
  | intro_neighborhood_net_DS U _ _ _ _,
    intro_neighborhood_net_DS V _ _ _ _ =>
    Included V U
  end.

Definition neighborhood_net_DS : DirectedSet.
refine (Build_DirectedSet neighborhood_net_DS_set
  neighborhood_net_DS_ord _ _).
- constructor;
    red; intros;
    destruct x0.
  + simpl. auto with sets.
  + destruct y, z.
    simpl in H, H0.
    simpl.
    auto with sets.
- intros.
  destruct i, j.
  assert (open (Intersection U U0)) by
    now apply open_intersection2.
  assert (In (Intersection U U0) x) by
    auto with sets.
  exists (intro_neighborhood_net_DS (Intersection U U0) x
    H H0 H0).
  simpl.
  auto with sets.
Defined.

Definition neighborhood_net : Net neighborhood_net_DS X :=
  fun (x:neighborhood_net_DS_set) => match x with
  | intro_neighborhood_net_DS _ y _ _ _ => y
  end.

Lemma neighborhood_net_limit: net_limit neighborhood_net x.
Proof.
red. intros.
exists (intro_neighborhood_net_DS U x H H0 H0).
intros.
destruct j.
simpl in H1.
simpl.
auto with sets.
Qed.

End neighborhood_net.

Lemma net_limits_determine_topology:
  forall {X:TopologicalSpace} (S:Ensemble X)
  (x0:X), In (closure S) x0 ->
  exists I:DirectedSet, exists x:Net I X,
  (forall i:DS_set I, In S (x i)) /\ net_limit x x0.
Proof.
intros.
assert (forall U:Ensemble X, open U -> In U x0 ->
  Inhabited (Intersection S U)).
{ intros.
  apply NNPP. intro.
  assert (Included (closure S) (Complement U)).
  { apply closure_minimal; red.
    - now rewrite Complement_Complement.
    - intros.
      intro.
      contradiction H2.
      exists x.
      auto with sets. }
  contradict H1.
  now apply H3. }
pose (Ssel := fun n:neighborhood_net_DS_set X x0 =>
  match n with
  | intro_neighborhood_net_DS V y _ _ _ => (In S y)
  end).
pose (our_DS_set := {n:neighborhood_net_DS_set X x0 | Ssel n}).
pose (our_DS_ord := fun (n1 n2:our_DS_set) =>
  neighborhood_net_DS_ord X x0 (proj1_sig n1) (proj1_sig n2)).
assert (preorder our_DS_ord).
{ constructor; red.
  - intros. red.
    apply preord_refl.
    apply (@DS_ord_cond (neighborhood_net_DS X x0)).
  - intros x y z.
    unfold our_DS_ord. apply preord_trans.
    apply (@DS_ord_cond (neighborhood_net_DS X x0)). }
assert (forall i j:our_DS_set, exists k:our_DS_set,
  our_DS_ord i k /\ our_DS_ord j k).
{ destruct i, x, j.
  destruct x.
  assert (open (Intersection U U0)) by
    now apply open_intersection2.
  assert (In (Intersection U U0) x0) by
    auto with sets.
  assert (Inhabited (Intersection S (Intersection U U0))) by
    now apply H0.
  destruct H4.
  destruct H4.
  pose (k0 := intro_neighborhood_net_DS X x0
    (Intersection U U0) x H2 H3 H5).
  assert (Ssel k0).
  { red. now unfold k0. }
  exists (exist _ k0 H6).
  split; red; simpl; auto with sets. }
pose (our_DS := Build_DirectedSet our_DS_set our_DS_ord H1 H2).
exists our_DS.
exists (fun i:our_DS_set => neighborhood_net X x0 (proj1_sig i)).
split.
- intros.
  now destruct i, x.
- red. intros.
  assert (Inhabited (Intersection S U)) by
    now apply H0.
  destruct H5.
  destruct H5.
  pose (i0 := intro_neighborhood_net_DS X x0
    U x H3 H4 H6).
  assert (Ssel i0) by trivial.
  exists (exist _ i0 H7).
  intros.
  destruct j, x1.
  simpl in H8.
  red in H8. simpl in H8.
  simpl.
  auto with sets.
Qed.

Section Nets_and_continuity.

Variable X Y:TopologicalSpace.
Variable f:X -> Y.

Lemma continuous_func_preserves_net_limits:
  forall {I:DirectedSet} (x:Net I X) (x0:X),
    net_limit x x0 -> continuous_at f x0 ->
    net_limit (fun i:DS_set I => f (x i)) (f x0).
Proof.
intros.
red. intros V ? ?.
assert (neighborhood V (f x0)).
{ apply open_neighborhood_is_neighborhood.
  now split. }
destruct (H0 V H3) as [U [? ?]].
destruct H4.
pose proof (H U H4 H6).
apply eventually_impl_base with (fun i:DS_set I => In U (x i));
  trivial.
intros.
assert (In (inverse_image f V) (x i)) by auto with sets.
now destruct H9.
Qed.

Lemma func_preserving_net_limits_is_continuous:
  forall x0:X,
  (forall (I:DirectedSet) (x:Net I X),
    net_limit x x0 -> net_limit (fun i:DS_set I => f (x i)) (f x0))
  -> continuous_at f x0.
Proof.
intros.
pose proof (H (neighborhood_net_DS X x0)
  (neighborhood_net X x0)
  (neighborhood_net_limit X x0)).
apply continuous_at_open_neighborhoods.
intros.
destruct H1, (H0 V H1 H2).
destruct x as [U].
exists U.
repeat split; trivial.
apply (H3 (intro_neighborhood_net_DS X x0 U x o i H4)).
simpl. auto with sets.
Qed.

End Nets_and_continuity.

Section Subnet.

Variable X:TopologicalSpace.
Variable I:DirectedSet.
Variable x:Net I X.

Inductive Subnet {J:DirectedSet} : Net J X -> Prop :=
  | intro_subnet: forall h:DS_set J -> DS_set I,
    (forall j1 j2:DS_set J, DS_ord j1 j2 ->
       DS_ord (h j1) (h j2)) ->
    (exists arbitrarily large i:DS_set I,
       exists j:DS_set J, h j = i) ->
    Subnet (fun j:DS_set J => x (h j)).

Lemma subnet_limit: forall (x0:X) {J:DirectedSet}
  (y:Net J X), net_limit x x0 -> Subnet y ->
  net_limit y x0.
Proof.
intros.
destruct H0.
red. intros.
destruct (H U H2 H3).
destruct (H1 x1).
destruct H5, H6.
exists x3.
intros.
apply H4.
apply preord_trans with x2; trivial.
- apply DS_ord_cond.
- rewrite <- H6.
  now apply H0.
Qed.

Lemma subnet_cluster_point: forall (x0:X) {J:DirectedSet}
  (y:Net J X), net_cluster_point y x0 ->
  Subnet y -> net_cluster_point x x0.
Proof.
intros.
destruct H0 as [h h_increasing h_dominant].
red. intros.
red. intros.
destruct (h_dominant i).
destruct H2, H3.
destruct (H U H0 H1 x2).
destruct H4.
exists (h x3).
split; trivial.
apply preord_trans with x1; trivial.
- apply DS_ord_cond.
- rewrite <- H3.
  now apply h_increasing.
Qed.

Section cluster_point_subnet.

Variable x0:X.
Hypothesis x0_cluster_point: net_cluster_point x x0.
Hypothesis I_nonempty: inhabited (DS_set I).

Record cluster_point_subnet_DS_set : Type := {
  cps_i:DS_set I;
  cps_U:Ensemble X;
  cps_U_open_neigh: open_neighborhood cps_U x0;
  cps_xi_in_U: In cps_U (x cps_i)
}.

Definition cluster_point_subnet_DS_ord
  (iU1 iU2 : cluster_point_subnet_DS_set) : Prop :=
  DS_ord (cps_i iU1) (cps_i iU2) /\
  Included (cps_U iU2) (cps_U iU1).

Definition cluster_point_subnet_DS : DirectedSet.
refine (Build_DirectedSet
  cluster_point_subnet_DS_set
  cluster_point_subnet_DS_ord
  _ _).
- constructor.
  + red. intros.
    split; auto with sets.
    apply preord_refl.
    apply DS_ord_cond.
  + red. intros.
    destruct H, H0.
    red. split; auto with sets.
    apply preord_trans with (cps_i y); trivial.
    apply DS_ord_cond.
- intros.
  destruct i as [i0 U0 ? ?].
  destruct j as [i1 U1 ? ?].
  destruct (DS_join_cond i0 i1).
  destruct H.
  pose proof (x0_cluster_point
    (Intersection U0 U1)).
  match type of H1 with | _ -> _ -> ?C =>
    assert C end.
  { apply H1.
    - apply open_intersection2;
        (apply cps_U_open_neigh0 ||
         apply cps_U_open_neigh1).
    - constructor.
      + apply cps_U_open_neigh0.
      + apply cps_U_open_neigh1. }
  destruct (H2 x1), H3.
  pose (ki := x2).
  pose (kU := Intersection U0 U1).
  assert (open_neighborhood kU x0).
  { split.
    - apply open_intersection2.
      + apply cps_U_open_neigh0.
      + apply cps_U_open_neigh1.
    - constructor.
      + apply cps_U_open_neigh0.
      + apply cps_U_open_neigh1. }
  assert (In kU (x ki)) by trivial.
  exists (Build_cluster_point_subnet_DS_set
    ki kU H5 H6).
  split; red; simpl; split.
  + apply preord_trans with x1; trivial.
    apply DS_ord_cond.
  + red. intros.
    now destruct H7.
  + apply preord_trans with x1; trivial.
    apply DS_ord_cond.
  + red. intros.
    now destruct H7.
Defined.

Definition cluster_point_subnet : Net
  cluster_point_subnet_DS X :=
  fun (iU:DS_set cluster_point_subnet_DS) =>
  x (cps_i iU).

Lemma cluster_point_subnet_is_subnet:
  Subnet cluster_point_subnet.
Proof.
constructor.
- intros.
  destruct j1, j2.
  simpl in H. simpl.
  red in H. tauto.
- red. intros.
  exists i. split.
  + apply preord_refl, DS_ord_cond.
  + assert (open_neighborhood Full_set x0).
    { repeat constructor.
      apply open_full. }
    assert (In Full_set (x i)) by
      constructor.
    now exists (Build_cluster_point_subnet_DS_set
      i Full_set H H0).
Qed.

Lemma cluster_point_subnet_converges:
  net_limit cluster_point_subnet x0.
Proof.
red. intros.
destruct I_nonempty as [i0].
destruct (x0_cluster_point U H H0 i0).
destruct H1.
assert (open_neighborhood U x0) by
  now split.
exists (Build_cluster_point_subnet_DS_set
  x1 U H3 H2).
intros.
destruct j.
red in H4. simpl in H4.
red in H4. simpl in H4.
unfold cluster_point_subnet. simpl.
destruct H4. auto with sets.
Qed.

Lemma net_cluster_point_impl_subnet_converges:
  exists J:DirectedSet, exists y:Net J X,
  Subnet y /\ net_limit y x0.
Proof.
exists cluster_point_subnet_DS.
exists cluster_point_subnet.
split.
- exact cluster_point_subnet_is_subnet.
- exact cluster_point_subnet_converges.
Qed.

End cluster_point_subnet.

End Subnet.
