module Main where

import           RIO
import           System.IO

import qualified Network.Wai.Handler.Warp      as Warp

import qualified Config.Config                 as Config
import qualified Adapter.EmailChecker          as EmailChecker
import qualified Adapter.Http.Router           as Router
import qualified Adapter.InMemory.UserRepo     as UserRepo
import qualified Adapter.Fake.Hasher           as Hasher
import qualified Adapter.Logger                as Logger
import qualified Adapter.UUIDGen               as UUIDGen

import qualified Usecase.Interactor            as UC
import qualified Usecase.LogicHandler          as UC
import qualified Usecase.UserRegistration      as UC
import qualified Usecase.UserLogin             as UC

main :: IO ()
main = do
  putStrLn "== Haskel Clean Architecture =="
  state  <- freshState
  router <- Router.start (logicHandler interactor) $ run state
  port   <- Config.getIntFromEnv "PORT" 3000
  putStrLn $ "starting server on port: " ++ show port
  Warp.run port router

type State = TVar UserRepo.Store
newtype App a = App (RIO State a) deriving (Applicative, Functor, Monad, MonadReader State, MonadIO)

run :: State -> App a -> IO a
run state (App app) = runRIO state app

interactor :: UC.Interactor App
interactor = UC.Interactor { UC._userRepo         = userRepo
                           , UC._checkEmailFormat = EmailChecker.checkEmailFormat
                           , UC._genUUID          = UUIDGen.genUUIDv4
                           , UC._hash             = Hasher.hash
                           }
 where
  userRepo = UC.UserRepo UserRepo.getUserByID
                         UserRepo.getUserByEmail
                         UserRepo.getUserByName
                         UserRepo.getUserByEmailAndHashedPassword

logicHandler :: UC.Interactor App -> UC.LogicHandler App
logicHandler i = UC.LogicHandler
  (UC.register (UC._genUUID i)
               (UC._checkEmailFormat i)
               (UC._getUserByEmail $ UC._userRepo i)
               (UC._getUserByName $ UC._userRepo i)
  )
  (UC.login (UC._hash i) (UC._getUserByEmailAndHashedPassword $ UC._userRepo i))


freshState :: (MonadIO m) => m State
freshState = newTVarIO $ UserRepo.Store mempty

instance UC.Logger App where
  log = Logger.log
