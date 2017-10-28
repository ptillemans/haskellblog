{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.BlogSpec (spec) where

import TestImport
import Data.Aeson

spec :: Spec
spec = withApp $ do
  describe "These tests describe the blog page" $ do
    it "check blog page" $ do
      get BlogR
      statusIs 200
      htmlAnyContain "h1" "Latest Posts"

    it "can accept new blogposts" $ do
      let article = "# Some Title\n\n\
                    \Containing some *strong* language." :: Text
          body = object [ "article" .= article ]
          encoded = encode body

      request $ do
        setMethod "POST"
        setUrl BlogR
        setRequestBody encoded
        addRequestHeader ("Content-Type", "application/json")

      statusIs 200

      (Entity _id blog:_) <- runDB $ selectList [BlogArticle ==. article] []
      assertEq "Should have" blog (Blog article Nothing)
