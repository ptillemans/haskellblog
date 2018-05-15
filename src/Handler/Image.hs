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
import Data.Text as T
import Database.MongoDB ((=:))

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

getImageR :: Text -> Handler TypedContent
getImageR imageId = do
  mfile <- runDB $ do
    bucket <- GFS.openDefaultBucket
    GFS.findOneFile bucket ["filename" =: imageId]
  source <- case mfile of
    Just file -> return $ transPipe runDB (GFS.sourceFile file)
    Nothing -> return $ return ()
  respondSource "image/jpeg" $ source .| awaitForever sendChunkBS


getImageUploadR :: Handler Html
getImageUploadR = do
  (formWidget, formEnctype) <- generateFormPost imageUploadForm
  defaultLayout $ do
    let (uploadFormId, uploadSubmitId) = imageUploadIds
    setTitle "Upload an Image"
    $(widgetFile "imageUpload")

uploadFile :: FileInfo -> Handler ()
uploadFile file = runDB $ do
  bucket <- GFS.openDefaultBucket
  _ <- runConduit $ fileSource file .| GFS.sinkFile bucket (fileName file)
  liftIO $ putStrLn "file uploaded"

postImageUploadHtml :: Handler Html
postImageUploadHtml = do
  ((result, formWidget), formEnctype) <- runFormPost imageUploadForm
  let (uploadFormId, uploadSubmitId) = imageUploadIds
  case result of
    FormSuccess upload -> uploadFile (formFile upload)
    _                  -> setMessage "<p>Invalid Input</p>"
  defaultLayout $ do
    setTitle "Upload an Image"
    $(widgetFile "imageUpload")


postImageUploadJson :: Handler Value
postImageUploadJson = do
  ((result, _), _) <- runFormPostNoToken imageUploadForm
  case result of
    FormSuccess upload -> do
      uploadFile (formFile upload)
      return $ object [ "filename" .= ("/image/" <> (fileName . formFile $ upload)) ]
    FormMissing ->
      return $ object [ "filename" .= (T.pack "missing-file") ]
    FormFailure ss ->
      return $ array ss


postImageUploadR :: Handler TypedContent
postImageUploadR =  selectRep $ do
  provideRep $ postImageUploadHtml
  provideRep $ postImageUploadJson
