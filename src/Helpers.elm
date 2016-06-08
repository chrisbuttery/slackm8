module Helpers exposing (..)

import Random
import List
import Json.Decode as Json
import Regex
import String
import Html exposing (Attribute)
import Html.Attributes exposing (classList)
import Model exposing (Member, Group)


filterMembers : List Member -> List Member
filterMembers team =
  List.filter (\member -> member.name /= "slackbot" && member.name /= "teambl") team

-- createGroups
-- Iterate a list of lists. Pass each sub list to `createGroup`

createGroups : String -> List (List Member) -> List Group
createGroups name list =
  List.indexedMap (\i lst -> createGroup name lst i) list


-- createGroup
-- Take a string, a list and an int and return a record

createGroup : String -> List Member -> Int -> Group
createGroup name group i =
  { group = group
  , title = (name ++ "-" ++ toString (i + 1))
  }


-- dasherize
-- Use a regex to replace spaces with -

dasherize : String -> String
dasherize str =
  str
    |> Regex.replace Regex.All (Regex.regex "\\s") (\_ -> "-")
    |> String.toLower


-- targetSelectedIndex
-- get the selected option index from a select box

targetSelectedIndex : Json.Decoder Int
targetSelectedIndex =
  Json.at [ "target", "selectedIndex" ] Json.int


-- classNames
-- Take a list of strings and apply them as class names

classNames : List String -> Attribute msg
classNames strings =
  classList (List.map (\str -> ( str, True )) strings)
