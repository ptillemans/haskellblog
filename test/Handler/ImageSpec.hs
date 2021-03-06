{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Handler.ImageSpec (spec) where

import TestImport
import Settings
import Data.Bson
import qualified Database.MongoDB.GridFS as GFS

spec :: Spec
spec = withApp $ do
  describe "These tests describe image uploading and serving" $ do
    it "check image upload page is protected" $ do
      get ImageUploadR
      statusIs 403

    it "allows the admin user to upload an image" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      let fname = "bat.jpg" :: String
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageUploadR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageUploadR
        addToken
        addFile "image" fname "image/jpeg"

      statusIs 200

      bucket <- runDB $ GFS.openDefaultBucket
      mFile <- runDB $ GFS.findOneFile bucket [ "filename" =: fname ]
      assertEq "image should be uploaded" (isJust mFile) True


    it "allows the web client to upload an image" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      let fname = "bat.jpg" :: String
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageUploadR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageUploadR
        addToken
        addRequestHeader ("accept", "application/json")
        addFile "image" fname "image/jpeg"

      statusIs 200
      printBody
      bodyContains $ "/image/" <> fname

      bucket <- runDB $ GFS.openDefaultBucket
      mFile <- runDB $ GFS.findOneFile bucket [ "filename" =: fname ]
      assertEq "image should be uploaded" (isJust mFile) True

    it "supports jpeg images" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      let fname = "bat.jpg" :: String
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageUploadR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageUploadR
        addToken
        addRequestHeader ("accept", "application/json")
        addFile "image" fname "image/jpeg"
      statusIs 200

      get $ ImageR (pack fname)
      statusIs 200

      assertHeader "Content-Type" "image/jpeg"


    it "supports png images" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      let fname = "test.png" :: String
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageUploadR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageUploadR
        addToken
        addRequestHeader ("accept", "application/json")
        addFile "image" fname "image/png"
      statusIs 200

      get $ ImageR (pack fname)
      statusIs 200

      assertHeader "Content-Type" "image/png"

    it "supports svg images" $ do
      app <- getTestYesod
      let admin = appAdminUid $ appSettings app
      let fname = "test.svg" :: String
      adminEntity <- createUser admin
      authenticateAs adminEntity

      get ImageUploadR
      statusIs 200

      request $ do
        setMethod "POST"
        setUrl ImageUploadR
        addToken
        addRequestHeader ("accept", "application/json")
        addFile "image" fname "image/svg"
      statusIs 200

      get $ ImageR (pack fname)
      statusIs 200

      assertHeader "Content-Type" "image/svg"
