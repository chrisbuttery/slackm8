import Html.App as Html

import Model exposing (model, Model)
import View exposing (view)
import Update exposing (update, Msg)
import Subscriptions exposing (subscriptions)
import Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
    ( nextModel, nextCmd ) =
      Update.update msg model
  in
    ( nextModel
    , Cmd.batch
        [ Ports.logExternal msg
        , nextCmd
        ]
    )


-- init
-- create a pair of model and Cmd Msg to expose to the app
-- check for `savedModel` otherwise use `initialModel`

init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
  ( Maybe.withDefault model savedModel, Cmd.none )


main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
