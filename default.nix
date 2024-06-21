{ mkDerivation, async, base, bytestring, conduit, lib
, optparse-applicative, relude, stm, text, uuid
}:
mkDerivation {
  pname = "generate-uuids-lib";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    async base bytestring conduit optparse-applicative relude stm text
    uuid
  ];
  executableHaskellDepends = [ base relude ];
  license = lib.licenses.mit;
  mainProgram = "generate-uuids";
}
