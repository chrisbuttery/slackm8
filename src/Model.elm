module Model exposing (..)


type alias Member =
  { id : String
  , team_id : String
  , name : String
  , real_name : String
  , avatar_sml : String
  , avatar_lrg : String
  }


type alias Group =
  { title : String
  , group : List Member
  }


type alias Model =
  { error : Maybe String
  , groups : Maybe (List (List Member))
  , isLoading : Bool
  , limit : Int
  , success : Bool
  , team : Maybe (List Member)
  , title : String
  , token : String
  }


-- model

model : Model
model =
  { error = Nothing
  , groups = Nothing
  , isLoading = False
  , limit = 1
  , success = False
  , team = Nothing
  , title = "Room"
  , token = ""
  }
