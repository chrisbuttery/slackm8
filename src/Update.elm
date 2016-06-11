module Update exposing (..)

import Random
import String
import Http
import Json.Decode as Json exposing ((:=))
import Task
import Model exposing (Member, Model)
import Shuffle exposing (shuffle)
import Split exposing (split)
import Helpers exposing (dasherize, filterMembers)
import Ports


type Msg
  = Close
  | CreateChannelFail Http.Error
  | CreateChannelSuccess (List Member) String String
  | FetchMembers
  | FetchMembersFail Http.Error
  | FetchMembersSucceed (List Member)
  | InviteMemberFail Http.Error
  | InviteMembersToChannels
  | InviteMemberSuccess Bool
  | SetLimit Int
  | SetTitle String
  | Shuffle
  | Split (List Member)
  | StoreToken String


-- update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Close ->
      ( { model
          | error = Nothing
          , success = False
        }
      , Cmd.none
      )

    CreateChannelFail err ->
      handleHttpError err model

    CreateChannelSuccess group token roomID ->
      model ! List.map (inviteMember token roomID << .id) group

    FetchMembers ->
      let
        model' =
          { model | isLoading = True }
      in
        ( model', fetchAllMembers model'.token )

    FetchMembersFail err ->
      handleHttpError err model

    FetchMembersSucceed result ->
      let
        filtered =
          filterMembers result
      in
        ( { model
            | isLoading = False
            , limit = List.length result
            , team = Just filtered
            , error = Nothing
          }
        , Random.generate Split (shuffle filtered)
        )

    InviteMemberFail err ->
      handleHttpError err model

    InviteMembersToChannels ->
      model ! List.indexedMap (\i grp -> createChannel i model.token model.title grp) model.groups

    InviteMemberSuccess bool ->
      ( { model
          | error = Nothing
          , success = True
        }
      , Cmd.none
      )

    SetLimit num ->
      let
        model' =
          { model | limit = num }
      in
        ( model', Ports.modelChange model' )

    SetTitle title ->
      let
        default =
          if title == "" then
            "Room"
          else
            title

        transformedTitle =
          default
            |> String.toLower
            |> dasherize

        model' =
          { model | title = transformedTitle }
      in
        ( model', Ports.modelChange model' )

    Shuffle ->
      case model.team of
        Just team ->
          ( model, Random.generate Split (shuffle team) )

        Nothing ->
          ( model, Cmd.none )

    Split list ->
      let
        model' =
          { model | groups = (split model.limit list) }
      in
        ( model', Ports.modelChange model' )

    StoreToken token ->
      ( { model | token = token }, Cmd.none )


-- handleHttpError
-- Handle a http error

handleHttpError : Http.Error -> Model -> ( Model, Cmd Msg )
handleHttpError err model =
  case err of
    Http.Timeout ->
      ( { model
          | error = Just "Timeout"
          , isLoading = False
        }
      , Cmd.none
      )

    Http.NetworkError ->
      ( { model
          | error = Just "Network Error"
          , isLoading = False
        }
      , Cmd.none
      )

    Http.UnexpectedPayload error ->
      ( { model
          | error = Just error
          , isLoading = False
        }
      , Cmd.none
      )

    Http.BadResponse code error ->
      ( { model
          | error = Just error
          , isLoading = False
        }
      , Cmd.none
      )


-- fetchAllMembers
-- method: GET
-- Retrieve all Members from a team (defaults to *** team)

fetchAllMembers : String -> Cmd Msg
fetchAllMembers token =
  Task.perform
    FetchMembersFail
    FetchMembersSucceed
    (Http.get decodeMembersResponse
      ("https://slack.com/api/users.list?token=" ++ token)
    )


-- decodeMembersResponse
-- pluck out the members array from the fetchAllMembers response
-- and iterate required data using decodeMembers

decodeMembersResponse : Json.Decoder (List Member)
decodeMembersResponse =
  Json.at [ "members" ] (Json.list decodeMembers)


-- decodeMembers
-- pluck out the id, team_id, name and real_name for each member


decodeMembers : Json.Decoder Member
decodeMembers =
  Json.object6 Member
    ("id" := Json.string)
    ("team_id" := Json.string)
    ("name" := Json.string)
    ("real_name" := Json.string)
    ("profile" := decodeSmlAvatar)
    ("profile" := decodeLrgAvatar)


-- decodeLrgAvatar
-- pluck the 'image_32' from profile

decodeLrgAvatar : Json.Decoder String
decodeLrgAvatar =
  Json.at [ "image_32" ] Json.string


-- decodeSmlAvatar
-- pluck the 'image_24' from profile

decodeSmlAvatar : Json.Decoder String
decodeSmlAvatar =
  Json.at [ "image_24" ] Json.string


-- createChannel
-- create a room for each group
-- passing in `title` as the room name
-- which will return the room id from `decodeCreateRoomResponse`

createChannel : Int -> String -> String -> List Member -> Cmd Msg
createChannel idx token title group =
  Task.perform
    CreateChannelFail
    (CreateChannelSuccess group token)
    (Http.post decodeCreateChannelResponse
      ("https://slack.com/api/channels.create?token="
      ++ token
      ++ "&name="
      ++ title
      ++ "-"
      ++ toString (idx + 1))
      Http.empty
    )



-- decodeCreateChannelResponse
-- return channel id from createChannel response

decodeCreateChannelResponse : Json.Decoder String
decodeCreateChannelResponse =
  Json.at [ "channel", "id" ] Json.string


-- inviteMember
-- add a Member to a room using a `room_id` and the Member's name
-- returns a bool from `decodeAddMemberResponse`

inviteMember : String -> String -> String -> Cmd Msg
inviteMember token channel_id user_id =
  Task.perform
    InviteMemberFail
    InviteMemberSuccess
    (Http.post decodeInviteMemberResponse
      ("https://slack.com/api/channels.invite?token="
        ++ token
        ++ "&channel="
        ++ channel_id
        ++ "&user="
        ++ user_id
      )
      Http.empty
    )


-- decodeInviteMemberResponse
-- return 'ok' status from inviteMember response

decodeInviteMemberResponse : Json.Decoder Bool
decodeInviteMemberResponse =
  Json.at [ "ok" ] Json.bool
