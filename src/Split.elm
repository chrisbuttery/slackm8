module Split exposing (..)


-- split
-- take an int to `take` and `drop` a selection of values from a list
-- recursively call `split` until nothing is available to `take` which
-- will return []
-- then start prepending `listHead`

-- Here is an example of how I understand it.
-- I could be very wrong.

-- i = 2
-- list = [1,2,3,4,5]
--
-- listHead = [1,2]
-- remaining [3,4,5]
--
-- recursively call `split` again with the remaining value
-- listHead = [3,4]
-- remaining [5]
--
-- recursively call `split` again with the remaining value
-- listHead = [5]
-- remaining []
--
-- start prepending:
-- [[5]]
--
-- [[3,4], [5]]
--
-- [[1,2], [3,4], [5]]

split : Int -> List a -> List (List a)
split i list =
  case List.take i list of
    [] -> []
    listHead -> listHead :: split i (List.drop i list)
