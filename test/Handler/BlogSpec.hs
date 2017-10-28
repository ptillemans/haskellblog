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

    it "allows the user to enter a blog post" $ do
      let article = "# Some Title\n\n\
                      \This is _underlined_." :: Text
      get BlogR

      request $ do
        setMethod "POST"
        setUrl BlogR
        addToken
        byLabel "Article" article

      statusIs 200

      (Entity _id blog:_) <- runDB $ selectList [BlogArticle ==. article] []
      assertEq "Should have" blog (Blog article Nothing)

    it "shows latest posts" $ do
      let article = "# Last Post\n\n\
                    \This is the last post"
          blog = Blog article Nothing
      _ <- runDB $ insert blog

      get BlogR
      statusIs 200
      htmlAnyContain "h1" "Last Post"
