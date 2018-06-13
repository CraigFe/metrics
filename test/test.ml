(*
 * Copyright (c) 2018 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

let src =
  let open Metrics in
  let tags = Tags.[
      "foo", int;
      "bar", string;
    ] in
  let fields i =
    Data.v [
      "toto", Data.string ("XXX" ^ string_of_int i);
      "titi", Data.int i
    ] in
  Src.push "test" ~tags ~fields

let i0 = Metrics.v src 42 "hi!"
let i1 = Metrics.v src 12 "toto"

let f i =
  Metrics.push i (fun m -> m 42);
  Metrics.push i (fun m -> m 43)

let set_reporter () =
  let report ~tags ~fields ?timestamp ~over src k =
    let name = Metrics.Src.name (Src src) in
    let pp =
      Fmt.(list ~sep:(unit ",") (pair ~sep:(unit "=") string Fmt.(quote string)))
    in
    let timestamp = match timestamp with
      | Some ts -> ts
      | None    -> Fmt.to_to_string Mtime.pp (Mtime_clock.now ())
    in
    Fmt.pr "%s %a %a %s\n%!" name pp tags pp fields timestamp;
    over ();
    k ()
  in
  let now () = Mtime_clock.now () |> Mtime.to_uint64_ns in
  Metrics.set_reporter { Metrics.report; now }

let () =
  set_reporter ();
  Metrics.enable_all ();
  f i0;
  f i1
