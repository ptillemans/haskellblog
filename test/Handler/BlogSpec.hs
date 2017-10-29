{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.BlogSpec (spec) where

import TestImport
import Yesod.Form.Fields
import Settings

spec :: Spec
spec = withApp $ do
  describe "These tests describe the blog page" $ do
    it "check blog page is protected" $ do
      get BlogR
      statusIs 403

    it "allows the admin user to enter a blog post" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      adminEntity <- createUser admin
      authenticateAs adminEntity
      let article = Textarea "# Some Title\n\n\
                      \This is _underlined_."
      get BlogR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl BlogR
        addToken
        byLabel "Title" $ "Some Title"
        byLabel "Article" $ unTextarea article

      statusIs 200

      (Entity _id blog:_) <- runDB $ selectList [BlogArticle ==. article] []
      assertEq "Should have" article (blogArticle blog)
