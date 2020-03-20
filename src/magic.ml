module Make (S : sig type +'a t end) = struct
  type t
  type +'a s = 'a S.t

  external prj : ('a, t) Process.io -> 'a S.t = "%identity"
  external inj : 'a S.t -> ('a, t) Process.io = "%identity"
end

module Unix_scheduler = Make(struct type +'a t = 'a end)

let unix =
  let open Unix_scheduler in
  { Process.bind= (fun x f -> f (prj x))
  ; Process.return= (fun x -> inj x) }

let lseek fd offset where = match where with
  | Process.SET -> Unix.lseek fd (Int64.to_int offset) Unix.SEEK_SET
  | Process.CUR -> Unix.lseek fd (Int64.to_int offset) Unix.SEEK_CUR
  | Process.END -> Unix.lseek fd (Int64.to_int offset) Unix.SEEK_END

let lseek fd offset where =
  try let ret = lseek fd offset where in
    assert (ret = Int64.to_int offset) ;
    Unix_scheduler.inj (Ok ())
  with uerror -> Unix_scheduler.inj (Error uerror)

let read fd len =
  let rs = Bytes.create len in
  let ic = Unix.in_channel_of_descr fd in
  try really_input ic rs 0 len ; Unix_scheduler.inj (Ok (Bytes.unsafe_to_string rs))
  with uerror -> Unix_scheduler.inj (Error uerror)

let read_int8 fd =
  let ic = Unix.in_channel_of_descr fd in
  try Unix_scheduler.inj (Ok (input_byte ic))
  with uerror -> Unix_scheduler.inj (Error uerror)

external get_uint16 : bytes -> int -> int = "%caml_bytes_get16"
external get_uint32 : bytes -> int -> int32 = "%caml_bytes_get32"
external get_uint64 : bytes -> int -> int64 = "%caml_bytes_get64"

let read_int16 fd =
  let ic = Unix.in_channel_of_descr fd in
  let rs = Bytes.create 2 in
  try really_input ic rs 0 2 ;
    Unix_scheduler.inj (Ok (get_uint16 rs 0))
  with uerror -> Unix_scheduler.inj (Error uerror)

let read_int32 fd =
  let ic = Unix.in_channel_of_descr fd in
  let rs = Bytes.create 4 in
  try really_input ic rs 0 4 ;
    Unix_scheduler.inj (Ok (get_uint32 rs 0))
  with uerror -> Unix_scheduler.inj (Error uerror)

let read_int64 fd =
  let ic = Unix.in_channel_of_descr fd in
  let rs = Bytes.create 8 in
  try really_input ic rs 0 8 ;
    Unix_scheduler.inj (Ok (get_uint64 rs 0))
  with uerror -> Unix_scheduler.inj (Error uerror)

let syscall =
  { Process.lseek= lseek
  ; Process.read= read
  ; Process.read_int8= read_int8
  ; Process.read_int16_ne= read_int16
  ; Process.read_int32_ne= read_int32
  ; Process.read_int64_ne= read_int64 }

let exit_success = 0
let exit_failure = 1

let pp_list pp_val ppf lst =
  let rec go = function
    | [] -> ()
    | [ x ] -> Format.fprintf ppf "%a" pp_val x
    | x :: r ->
      Format.fprintf ppf "%a;@ " pp_val x ; go r in
  go lst

let pp_list pp_val ppf lst =
  Format.fprintf ppf "[@[<hov>%a]@]]" (pp_list pp_val) lst

let process description filename =
  let desc = open_in description in
  match Parse.parse_in_channel desc with
  | Error err ->
    Format.eprintf "[parser] %a.\n%!" Parse.pp_error err ;
  | Ok lst ->
    let fd = Unix.openfile filename Unix.[ O_RDONLY ] 0o644 in
    let tree = Tree.Done in
    let tree = List.fold_left Tree.append tree lst in
    match Unix_scheduler.prj (Process.ascending_walk unix syscall fd tree) with
    | results ->
      Format.printf "%a" (pp_list Process.pp_metadata) results

let () = match Sys.argv with
  | [| _; description; filename; |] -> process description filename
  | _ -> Format.eprintf "%s description filename\n%!" Sys.argv.(0)
