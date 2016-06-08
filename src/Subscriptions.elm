module Subscriptions exposing (..)

import Model exposing (Model)
import Update exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions =
  \_ -> Sub.none
