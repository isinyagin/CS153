open Mlish_ast
open Environment 

exception TypeError

let type_error(s:string) = print_string s; raise TypeError

(* Guess Manipulators *)

(* Unifies types *)
let rec unify a_type b_type = 
  (* Compare for easy equality *)
  if (a_type = b_type) then true
  else 
  match (a_type, b_type) with 
  | (Guess_t(r_guess), b_type)  -> 
      (match !r_guess with 
      (* If a_ is not yet assigned, assign it  *)
      | None -> let _ = r_guess := Some b_type in true
      (* If a_ is a guess, try to resolve it   *)
      | Some(t_guess) -> unify t_guess b_type)
  (* If b_ is a guess, use a_ to assign it *)
  | (a_type, Guess_t(_))        -> unify b_type a_type

  (* Recurse if functions involved *)
  | (Fn_t(l_atype, r_atype), Fn_t(l_btype, r_btype)) ->  
    (unify l_atype r_atype) && (unify l_btype r_btype)
  | _ -> (type_error "Unable to unify")

(* Creates a new Guess *)
let guess () = 
  Guess_t(ref None)

(* Follows guess links until an end is found *)
let rec resolve t_type = 
  match t_type with
  | Guess_t(rt_guess) -> (match !rt_guess with
                         | None -> None
                         | Some(n_type) -> resolve n_type)
  | _                 -> Some(t_type)

(* Attempts to resolve a type, setting it if it isnt assigned *)
let rec resolve_or_set (t_type : tipe) (set_type : tipe)  : tipe = 
  match t_type with
  | Guess_t(rt_guess)  -> 
      (match !rt_guess with
      (* If a_ is not yet assigned, assign it  *)
      | None -> let _ = rt_guess := Some set_type in set_type
      (* If a_ is a guess, try to resolve it   *)
      | Some t_guess -> resolve_or_set t_guess set_type)
  | _  -> t_type

(* Type Checks *)

let rec check_exp e env = 
  (* Extract rexp *)
  let (t_rexp, _) = e in
  check_rexp t_rexp env

and check_rexp (t_rexp : rexp) env = 
  (* Segregate expressions *)
  match t_rexp with
  | Var(v)                 -> check_var v env
  | PrimApp(p, exps)       -> check_prim p exps env
  | Fn(v, t_exp)           -> check_fn v t_exp env
  | App(t_exp, o_exp)      -> check_app t_exp o_exp env
  | If(cond, t_exp, e_exp) -> check_if cond t_exp e_exp env
  | Let(v, t_exp, in_exp)  -> check_let v t_exp in_exp env

and check_var v env =
  (* Look up var *)
  lookup v env

and check_prim p (exps : exp list) env = 
  (* Match primitive possibilities *)
  match (p, exps) with 
  (* Raw *)
  | (Int(i),  [])  -> Int_t
  | (Bool(b), [])  -> Bool_t
  | (Unit,    [])  -> Unit_t

  (* Int ops *)
  | (Plus, [e1; e2])  ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Int_t 
                          else (type_error "Int expected for Plus")
  | (Minus, [e1; e2]) ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Int_t 
                          else (type_error "Int expected for Minus")
  | (Times, [e1; e2]) ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Int_t 
                          else (type_error "Int expected for Times")
  | (Div, [e1; e2])   ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Int_t 
                          else (type_error "Int expected for Div")
  | (Eq, [e1; e2])    ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Bool_t 
                          else (type_error "Int expected for Eq")
  | (Lt, [e1; e2])    ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          if (unify e1_check e2_check) && (e1_check = Int_t)
                          then Bool_t 
                          else (type_error "Int expected for Lt")
  (* Pairs *)
  | (Pair, [e1; e2])  ->  let e1_check = (check_exp e1 env) in
                          let e2_check = (check_exp e2 env) in
                          Pair_t(e1_check, e2_check)

  | (Fst, [e1])       ->  let check = (check_exp e1 env) in 
                          (match check with 
                          | Pair_t(fst_type, _) -> fst_type
                          | t                   -> (type_error ("Pair expected for Fst vs "^(type_to_string t))))
     
  | (Snd, [e1])       ->  let check = (check_exp e1 env) in 
                          (match check with 
                          | Pair_t(_, snd_type) -> snd_type
                          | t                   -> (type_error ("Pair expected for Snd vs "^(type_to_string t))))
  (* Lists *)
  | (Nil, [])         -> List_t(guess ())
  | (Cons, [e1; e2])  -> let e1_check = (check_exp e1 env) in
                         let e2_check = (check_exp e2 env) in
                         if unify e1_check e2_check then List_t(e1_check)
                         else (type_error "Pair expected for Cons")
  | (IsNil, [t_list]) -> let l_check = (check_exp t_list env) in
                         (match l_check with 
                         | List_t(_) -> Bool_t
                         | _         -> (type_error "List expected for IsNil"))
  | (Hd, [t_list])    -> let l_check = (check_exp t_list env) in
                         (match l_check with 
                         | List_t(l_type) -> l_type
                         | _              -> (type_error "List expected for Hd"))
  | (Tl, [t_list])    -> let l_check = (check_exp t_list env) in
                         (match l_check with 
                         | List_t(l_type) -> List_t(l_type)
                         | _              -> (type_error "List expected for Tl"))
  | _ -> (type_error "Unknown Primitive")

and check_fn v t_exp env = 
  (* Add v to the env as a guess *)
  let arg_type = guess () in
  let new_env = push v arg_type env in
  (* Check body *)
  let body_type = check_exp t_exp new_env in
  (* Return function type *)
  Fn_t(arg_type, body_type) 

and check_app t_exp o_exp env = 
  (* Return type is a guess *)
  let return_type = guess () in
  (* Type check both expressions *)
  let (t_type, o_type) = ((check_exp t_exp env), (check_exp o_exp env)) in
  (* Unify first expression as a function that can take the second *)
  if unify t_type (Fn_t(o_type, return_type)) then return_type 
  else (type_error "Unable to unify in apply")

and check_if cond t_exp e_exp env = 
  (* Check condition for bool *)
  let cond_check = check_exp cond env in
  let resolved_type = resolve_or_set cond_check Bool_t in
  if not (resolved_type = Bool_t || resolved_type = Int_t) then (type_error ("Bool condition needed for If vs "^(type_to_string resolved_type)))
  else 
    let t_check = check_exp t_exp env in
    let e_check = check_exp e_exp env in
    (* Check t_exp and e_exp for equality, type *)
    if unify t_check e_check then t_check
    else (type_error ("Unable to unify If: "^(type_to_string t_check)^" vs "^(type_to_string e_check)))

and check_let v t_exp in_exp env =
  (* Check t_exp *)
  let t_type = check_exp t_exp env in
  let new_env = push v t_type env in 
  (* Check in_exp with new environemnt *)
  check_exp in_exp new_env

(* Entry Point *)

let type_check_exp (e:Mlish_ast.exp) : tipe =
  (check_exp e empty_env)