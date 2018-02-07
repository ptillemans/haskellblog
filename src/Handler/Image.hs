{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Handler.Image where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import qualified Database.MongoDB.GridFS as GFS
-- import Debug.Trace (trace)



data ImageUploadForm = ImageUploadForm {
  formFile :: FileInfo
}

imageUploadIds :: (Text, Text)
imageUploadIds = ("upload-form", "upload-submit")

imageUploadForm :: Form ImageUploadForm
imageUploadForm = renderBootstrap3 BootstrapBasicForm $ ImageUploadForm
  <$> areq fileField FieldSettings { fsLabel = "Image"
                                   , fsTooltip = Just "Select the file to upload"
                                   , fsId = Just "image"
                                   , fsName = Just "image"
                                   , fsAttrs = [] } Nothing

getImageR :: ImageId -> Handler Html
getImageR imageId = error "Not yet implemented: getImageR"

deleteImageR :: ImageId -> Handler Html
deleteImageR imageId = error "Not yet implemented: deleteImageR"

getImageUploadR :: Handler Html
getImageUploadR = trace "getImageUploadR" $ do
  (formWidget, formEnctype) <- generateFormPost imageUploadForm
  defaultLayout $ do
    let (uploadFormId, uploadSubmitId) = imageUploadIds
    setTitle "Upload an Image"
    $(widgetFile "imageUpload")

postImageUploadR :: Handler Html
postImageUploadR = trace "postImageUploadR" $ do
  ((result, formWidget), formEnctype) <- runFormPost imageUploadForm
  let (uploadFormId, uploadSubmitId) = imageUploadIds
  case result of
    FormSuccess upload -> trace "form success" $ do
      _ <- runDB $ trace "uploading image" $ do
        bucket <- GFS.openDefaultBucket
        let file = formFile upload
        runConduit $ fileSource file .| GFS.sinkFile bucket (fileName file)
      defaultLayout $ do
        setTitle "Upload an Image"
        $(widgetFile "imageUpload")
    _ -> trace "form failed" $ do
      _ <- setMessage "<p>Invalid Input</p>"
      defaultLayout $ do
        setTitle "Upload an Image"
        $(widgetFile "imageUpload")
