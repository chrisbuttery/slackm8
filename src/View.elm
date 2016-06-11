module View exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import List
import Json.Decode as Json
import Dict

import Helpers exposing (createGroups, targetSelectedIndex, classNames)
import Model exposing (Member, Group, Model)
import Split exposing (split)
import Update exposing (Msg(..))


-- optionValues
-- define a list of ints from 0 to `max`

optionValues : Int -> List Int
optionValues max =
  [0..max]


-- renderDescription
-- app blurb

renderDescription : Html Msg
renderDescription =
  div [ class "description" ] [
    p [] [ text "Randomly shuffle a team into groups & invite members to Slack channels"]
  ]


-- renderTeam
-- render a teams list of members

renderTeam : List Member -> Bool -> Html Msg
renderTeam team isLoading =
  div [ class "team" ] [
    h3 [ class "team__title" ] [ text "Team" ]
    , div [ class "team__members" ] (List.map (\member -> renderTeamMember member) team)
    , renderLoading isLoading
  ]


-- renderTeamMember
-- render a team member with a sml avatar

renderTeamMember : Member -> Html Msg
renderTeamMember member =
  div [ class "member" ] [
    img [ classNames ["profile", "profile--sml", "u-mr-sml"], src member.avatar_sml ] []
    , span [ class "username" ] [ text ("@" ++ member.name) ]
  ]


-- renderGroups
-- render the groups containing element

renderGroups : String -> List (List Member) -> Html Msg
renderGroups title groups =
  div
    [ class "results" ]
    (List.map renderGroup (createGroups title groups))


-- renderGroup
-- render a Group of shuffled / split Members

renderGroup : Group -> Html Msg
renderGroup obj =
  div [ class "group"] [
    h2 [ classNames ["group__title", "u-mr-lrg"] ] [ text obj.title ]
    , div [ class "group__members" ] ( List.map renderGroupMember obj.group )
  ]


-- renderGroupMember
-- render a group's team member with a lrg avatar

renderGroupMember : Member -> Html Msg
renderGroupMember member =
  div [ class "member" ] [
    img [ classNames ["profile", "u-mr-sml"], src member.avatar_lrg ] []
    , span [ class "username" ] [ text ("@" ++ member.name) ]
  ]


-- renderTokenForm
-- render a view to require slack api token

renderTokenForm : Model -> Html Msg
renderTokenForm model =
  let
    error =
      Maybe.withDefault "" model.error
  in
    div [ class "actions--token" ] [
      p [] [ text "Enter your Slack API authorization test token"]
      , div [ classList [( "error", True), ("hidden", error == ""), ("inline-block", error /= "")]] [
        p [ class "message" ] [ text error ]
        , span [ class "close", onClick Close ] [ text "close"]
      ]
      , div [] [
        input [
          placeholder "xoxp-123456...",
          onInput StoreToken
        ] []
        , button [ classNames ["btn"], onClick FetchMembers ] [ text "Fetch Team" ]
      ]
    ]


-- renderActions
-- render the main actions bar

renderActions : Model -> Html Msg
renderActions model =
  let
    selectEvent =
      on "change" (Json.map SetLimit targetSelectedIndex )

    isDisabled =
      if model.limit == 0 then True else False
  in
    div
      [ class "actions--main" ] [
        div [ class "actions--invite" ] [
          renderChannelActions model.groups model.limit
        ]
        , div [ class "actions--shuffle" ] [
          input [ class "inline-block", type' "text", placeholder "Type room name", onInput SetTitle ] []
          , div [ class "select-group" ] [
            label [ class "select-group__label"] [ text "Groups of" ]
            , select [ class "select-group__select", selectEvent ]
              (List.map (\val ->
                option [ selected (model.limit == val), value (toString val) ] [
                  text (toString val)
                ]
              ) (optionValues (List.length (Maybe.withDefault [] model.team))))
          ]
          , button
            [ classNames ["btn", "inline-block" ], disabled isDisabled , (onClick Shuffle) ]
            [ text "Shuffle" ]
        ]
      ]


-- renderChannelActions
-- render the "Create and invite" button

renderChannelActions : List (List Member) -> Int -> Html Msg
renderChannelActions groups limit =
  let
    isDisabled =
      if groups == [] || limit == 0
      then True
      else False
  in
    div [ class "actions--channel"] [
      button
       [ disabled isDisabled, class "btn" , (onClick InviteMembersToChannels) ]
       [ text "Create and invite" ]
    ]


-- renderLoading
-- rendering a loading state

renderLoading : Bool -> Html Msg
renderLoading isLoading =
  div [ classList [("is-loading", True), ("hidden", isLoading == False)] ] [
    text "is loading"
  ]


-- renderMain
-- render the main section of the app

renderMain : Model -> Html Msg
renderMain model =
  let
    error =
      Maybe.withDefault "" model.error
  in
    div [] [
      renderActions model
      , div [ classList [( "error", True), ("hidden", error == "")]] [
        p [ class "message" ] [ text error ]
        , span [ class "close", onClick Close ] [ text "close"]
      ]
      , div [ classList [( "success", True), ("hidden", model.success == False), ("inline-block", model.success == True)] ] [
        p [ class "message" ] [ text "Channels have been created and members have successfully been invited!"]
        , span [ class "close", onClick Close ] [ text "close"]
      ]
      , renderGroups model.title model.groups
    ]


-- renderHeader
-- render the header of the app

renderHeader : Html Msg
renderHeader =
  div [ class "header"] [
    h1 [ class "app-title" ] [ text "slackm8" ]
  ]


-- renderRefreshActions
-- render the "Refetch Team" button

renderRefreshActions : List Member -> Html Msg
renderRefreshActions team =
  div
    [ classList [("action--refresh", True), ("hidden", team == [])] ] [
      button [
        classNames ["btn", "btn--text"]
        , onClick FetchMembers ] [ text "Refetch Team" ]
    ]

-- view
-- give them something to look at

view : Model -> Html Msg
view model =
  let
    team =
      Maybe.withDefault [] model.team

    renderView =
      if model.token == "" || team == []
      then renderTokenForm
      else renderMain
  in
    div [ class "container"] [
      div [ classNames ["column",  "u-p-lrg"] ] [
        renderHeader
        , renderDescription
        , renderTeam team model.isLoading
        , renderRefreshActions team
      ]
      , div [ class "main" ] [
        renderView model
      ]
    ]
