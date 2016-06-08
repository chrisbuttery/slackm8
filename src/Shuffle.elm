module Shuffle exposing (..)

import Random


-- Props goes to Rob Hoelz @holezro for writing this.
-- https://gist.github.com/hoelzro/a49d796f2812714ec371
-- Thank you!


-- extractValueHelper

extractValueHelper : List a -> Int -> List a -> (a, List a)
extractValueHelper values index accumulator =
  case (index, values) of
    (_, []) -> Debug.crash "Out of values to extract"
    (0, (head::tail)) -> (head, List.append (List.reverse accumulator) tail)
    (_, (head::tail)) -> extractValueHelper tail (index - 1) <| head :: accumulator


-- extractValue

extractValue : List a -> Int -> (a, List a)
extractValue values index = extractValueHelper values index []


-- shuffle

shuffle : List a -> Random.Generator (List a)
shuffle values =
  case values of
    [] -> Random.map (\_ -> []) Random.bool
    values ->
      let randomIndexGenerator = Random.int 0 <| (List.length values) - 1
          extractAndRecurse = \index ->
            let (randomHead, remainder) = extractValue values index
                remainderGen = shuffle remainder
            in Random.map (\randomTail -> randomHead :: randomTail) remainderGen
      in Random.andThen randomIndexGenerator extractAndRecurse
