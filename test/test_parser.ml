let () = Printexc.record_backtrace true

let test_parser filename =
  Alcotest.test_case filename `Quick @@ fun () ->
  let open Conan in
  let ic = open_in ("../database/" ^ filename) in
  match Parse.parse_in_channel ic with
  | Ok _ ->
      close_in ic;
      Alcotest.(check pass) "parser" () ()
  | Error err ->
      close_in ic;
      Alcotest.failf "%a" Parse.pp_error err

let test_tree filename =
  Alcotest.test_case filename `Quick @@ fun () ->
  let open Conan in
  let ic = open_in ("../database/" ^ filename) in
  match Parse.parse_in_channel ic with
  | Ok lst ->
      let _tree =
        List.fold_left
          (fun (i, acc) line ->
            Format.eprintf "Append line %d.\n%!" i;
            (succ i, Tree.append acc line))
          (1, Tree.empty) lst
      in
      close_in ic;
      Alcotest.(check pass) "tree" () ()
  | Error err ->
      close_in ic;
      Alcotest.failf "%a" Parse.pp_error err

let database =
  [
    "acorn";
    "adi";
    "adventure";
    "algol68";
    "allegro";
    "alliant";
    "alpha";
    "amanda";
    "amigaos";
    "android";
    "animation";
    "aout";
    "apache";
    "apl";
    "apple";
    "application";
    "applix";
    "apt";
    "archive";
    "asf";
    "assembler";
    "asterix";
    "att3b";
    "audio";
    "basis";
    "beetle";
    "ber";
    "bflt";
    "bhl";
    "bioinformatics";
    "biosig";
    "blackberry";
    "blcr";
    "blender";
    "blit";
    "bout";
    "bsdi";
    "bsi";
    "btsnoop";
    "c64";
    "cad";
    "cafebabe";
    "cbor";
    "cddb";
    "chord";
    "cisco";
    "citrus";
    "c-lang";
    "clarion";
    "claris";
    "clipper";
    "clojure";
    "coff";
    "commands";
    "communications";
    "compress";
    "console";
    "convex";
    "coverage";
    "cracklib";
    "ctags";
    "ctf";
    "cubemap";
    "cups";
    "dact";
    "database";
    "dataone";
    "dbpf";
    (* "der"; *)
    "diamond";
    "diff";
    "digital";
    "dolby";
    "dump";
    "dyadic";
    "ebml";
    "edid";
    "editors";
    "efi";
    "elf";
    "encore";
    "epoc";
    "erlang";
    "espressif";
    "esri";
    "etf";
    "fcs";
    "filesystems";
    "finger";
    "flash";
    "flif";
    "fonts";
    "forth";
    "fortran";
    "frame";
    "freebsd";
    "fsav";
    "fusecompress";
    "games";
    "gcc";
    "gconv";
    "geo";
    "geos";
    "gimp";
    "git";
    "glibc";
    "gnome";
    "gnu";
    "gnumeric";
    "gpt";
    "gpu";
    "grace";
    "graphviz";
    "gringotts";
    "guile";
    "hardware";
    "hitachi-sh";
    "hp";
    "human68k";
    "ibm370";
    "ibm6000";
    "icc";
    "iff";
    "images";
    "inform";
    "intel";
    "interleaf";
    "island";
    "ispell";
    "isz";
    "java";
    "javascript";
    "jpeg";
    "karma";
    "kde";
    "keepass";
    "kerberos";
    "kicad";
    "kml";
    "lecter";
    "lex";
    "lif";
    "linux";
    "lisp";
    "llvm";
    "lua";
    "luks";
    "m4";
    "mach";
    "macintosh";
    "macos";
    "magic";
    "mail.news";
    "make";
    "map";
    "maple";
    "marc21";
    "mathcad";
    "mathematica";
    "matroska";
    "mcrypt";
    "measure";
    "mercurial";
    "metastore";
    "meteorological";
    "microfocus";
    "mime";
    "mips";
    "mirage";
    "misctools";
    "mkid";
    "mlssa";
    "mmdf";
    "modem";
    "modulefile";
    "motorola";
    "mozilla";
    "msdos";
    "msooxml";
    "msvc";
    "msx";
    "mup";
    "music";
    "nasa";
    "natinst";
    "ncr";
    "neko";
    "netbsd";
    "netscape";
    "netware";
    "news";
    "nitpicker";
    "numpy";
    "oasis";
    "ocaml";
    "octave";
    "ole2compounddocs";
    "olf";
    "openfst";
    "opentimestamps";
    "os2";
    "os400";
    "os9";
    "osf1";
    "palm";
    "parix";
    "parrot";
    "pascal";
    "pbf";
    "pbm";
    "pc88";
    "pc98";
    "pdf";
    "pdp";
    "perl";
    "pgf";
    "pgp";
    "pkgadd";
    "plan9";
    "plus5";
    "pmem";
    "polyml";
    "printer";
    "project";
    "psdbms";
    "psl";
    "pulsar";
    "pwsafe";
    "pyramid";
    "python";
    "qt";
    "revision";
    "riff";
    "rinex";
    "rpi";
    "rpm";
    "rpmsg";
    "rst";
    "rtf";
    "ruby";
    "sc";
    "sccs";
    "scientific";
    "securitycerts";
    "selinux";
    "sendmail";
    "sequent";
    "sereal";
    "sgi";
    "sgml";
    "sharc";
    "sinclair";
    "sisu";
    "sketch";
    "smalltalk";
    "smile";
    "sniffer";
    "softquad";
    "sosi";
    "spec";
    "spectrum";
    "sql";
    "ssh";
    "ssl";
    "sun";
    "symbos";
    "sysex";
    "tcl";
    "teapot";
    "terminfo";
    "tex";
    "tgif";
    "ti-8x";
    "timezone";
    "tplink";
    "troff";
    "tuxedo";
    "typeset";
    "unicode";
    "unknown";
    "uterus";
    "uuencode";
    "vacuum-cleaner";
    "varied.out";
    "varied.script";
    "vax";
    "vicar";
    "virtual";
    "virtutech";
    "visx";
    "vms";
    "vmware";
    "vorbis";
    "vxl";
    "warc";
    "weak";
    "webassembly";
    "windows";
    "wireless";
    "wordprocessors";
    "wsdl";
    "x68000";
    "xdelta";
    "xenix";
    "xilinx";
    "xo65";
    "xwindows";
    "yara";
    "zfs";
    "zilog";
    "zip";
    "zyxel";
  ]

let () =
  Alcotest.run "conan"
    [
      ("parser", List.map test_parser database);
      ("tree", List.map test_tree database);
    ]
