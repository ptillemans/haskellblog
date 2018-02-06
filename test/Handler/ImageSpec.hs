{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.ImageSpec (spec) where

import TestImport
import Yesod.Form.Fields
import Settings
import qualified Database.MongoDB.GridFS as GFS

spec :: Spec
spec = withApp $ do
  describe "These tests describe image uploading and serving" $ do
    it "check image upload page is protected" $ do
      get ImageR
      statusIs 403

    it "allows the admin user to upload an image" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageR
        addToken
        addFile "image" "test/data/bat.jpg" "image/jpeg"

      statusIs 200

      bucket <- runDB $ GFS.openDefaultBucket
      mFile <- runDB $ GFS.findOneFile bucket ["filename" := "bat.jpg"]
      assertNotEq "Should have image" mFile Nothing
