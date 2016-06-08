port module Ports exposing (..)

import Model exposing (Model)

-- modelChange
-- Log a stripped version of the model

port modelChange : Model -> Cmd msg

port logExternalOut : String -> Cmd msg

logExternal : a -> Cmd msg
logExternal value =
  logExternalOut (toString value)
