#|
  This file is a part of TyNETv5/Radiance
  (c) 2013 TymoonNET/NexT http://tymoon.eu (shinmera@tymoon.eu)
  Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package :radiance)

(define-interface core)

(define-interface dispatcher
  (dispatch (request)
    (:documentation "Dispatch a new webserver call."))
  (register (hook module uri)
    (:documentation "Register a hook to dispatch to on the given URI."))
  (unregister (uri)
    (:documentation "Free a given URI."))
  (effective-trigger (uri)
    (:documentation "Return the trigger and URI that would be called on the given request URI."))
  (dispatch-default (request)
    (:documentation "The standard method to invoke when no specific handler has been found.")))

(define-interface user
  (class ()
   (:documentation "User base class")
   (:type :class))
  (get (username)
    (:documentation "Returns the user object of an existing user or creates a new hull instance."))
  (field (user field &key value)
    (:documentation "Set or get a user data field."))
  (save (user)
    (:documentation "Save the user to the database."))
  (saved-p (user)
    (:documentation "Returns T if the user is not a hull instance, otherwise NIL."))
  (check (user branch)
    (:documentation "Checks if the user has access to that permissions branch"))
  (grant (user branch)
    (:documentation "Give permission to a certain branch."))
  (prohibit (user branch)
    (:documentation "Reclaim/Prohibit permission to a certain branch."))
  (action (user action &key public)
    (:documentation "Record an action for the user. If public is NIL, the action should not be visible to anyone else.."))
  (get-actions (user n &key public oldest-first)
    (:documentation "Returns a list of n cons cells, with the car being the action and the cdr being the time of the action.")))

(defmethod getdf ((user user:class) field)
  (user:field user field))

(define-interface auth
  (authenticate ()
    (:documentation "Authenticate the current user using whatever method applicable. Returns the user object."))
  (page-login (&key redirect)
    (:documentation "Returns an URL to the login page of the auth system. If redirect is provided, the user will be taken to that page afterwards."))
  (page-logout (&key redirect)
    (:documentation "Returns an URL to the logout page of the auth system. If redirect is provided, the user will be taken to that page afterwards."))
  (page-register (&key redirect)
    (:documentation "Returns an URL to the registration page of the auth system. If redirect is provided, the user will be taken to that page afterwards."))
  (page-options (&key target)
    (:documentation "Either displays a full options page or inserts all necessary things into the target if provided.")))

(define-interface session
  (class ()
    (:documentation "Sessions base class")
    (:type :class))
  (get (uuid)
    (:documentation "Returns the session for the given UUID or NIL if no session is found."))
  (get-all ()
    (:documentation "Return all sessions."))
  (start (username)
    (:documentation "Creates a new session object for the given user."))
  (start (user)
    (:documentation "Creates a new session object for the given user."))
  (start-temp ()
    (:documentation "Creates a temporary session without a bound user."))
  (uuid (session)
    (:documentation "Returns the uuid for this session."))
  (user (session)
    (:documentation "Returns the user associated with this session."))
  (field (session field &key value)
    (:documentation "Set or get a session data field."))
  (end (session)
    (:documentation "Finalizes the session object and in effect logs the user out."))
  (active-p (session)
    (:documentation "Returns T if the session is still active, otherwise NIL."))
  (temp-p (session)
    (:documentation "Returns T if the session is only temporary, otherwise NIL.")))

(define-interface profile
  (field (user name &key value default)
    (:documentation "Retrieves or sets a custom user field. If the field is unset or does not exist, the default value is returned."))
  (avatar (user size)
    (:documentation "Returns an URL to the avatar of the user, in the closest available size to the one requested."))
  (name (user)
    (:documentation "Returns the displayable name of the user."))
  (page-settings (user)
    (:documentation "Returns the URL to the settings page for the user."))
  (page-user (user)
    (:documentation "Returns the URL to the user's profile page."))
  (define-panel (name category (&key module (modulevar (gensym "MODULE-")) lquery access-branch menu-icon menu-tooltip) &body body)
    (:type :MACRO)))

(define-interface db
  (connect (dbname)
    (:documentation "Connects to the database given the information in the arguments."))
  (disconnect ()
    (:documentation "Disconnects the database"))
  (connected-p ()
    (:documentation "Returns T if the database is connected, otherwise NIL."))
  (collections ()
    (:documentation "Returns a list of all existing collections."))
  (create (collection fields &key indices (if-exists :ignore))
    (:documentation "Create a new collection with an optional list of indexed fields."))
  (empty (collection)
    (:documentation "Remove all records from this collection."))
  (drop (collection)
    (:documentation "Delete this collection entirely."))
  (select (collection query &key fields skip limit sort) 
    (:documentation "Retrieve data from the collection. Query should be constructed with the query macro."))
  (iterate (collection query function &key fields skip limit sort) 
    (:documentation "Iterate over data in the collection. Query should be constructed with the query macro. Might be faster than SELECT."))
  (insert (collection data) 
    (:documentation "Insert the data into the collection. Data is a list of alists."))
  (remove (collection query &key (skip 0) (limit 0) sort) 
    (:documentation "Delete data from the collection. Query should be constructed with the query macro."))
  (update (collection query data &key skip limit sort replace) 
    (:documentation "Update data in the collection. Query should be constructed with the query macro and data is a list of alists."))
  (apropos (collection)
    (:documentation "Returns a list of all available fields and their type or NIL if any field is possible."))
  (query (&rest statements)
    (:documentation "Query macro to construct database queries. Usable functions include: := :<= :>= :< :> :in :matches :and :or :not")
    (:type :MACRO)))

(define-interface data-model
  (class ()
    (:documentation "Data-model base class.")
    (:type :class))
  (id (model)
    (:documentation "Returns the UID of the model."))
  (field (model field &key value)
    (:documentation "Returns the value of a field. Is setf-able.")) 
  (get (collection query &key (skip 0) (limit 0) sort)
    (:documentation "Returns a list of model instances built from the query result."))
  (get-one (collection query &key (skip 0) sort)
    (:documentation "Returns the model instance of the first query result."))
  (hull (collection)
    (:documentation "Returns an empty model hull that can be used to insert data."))
  (hull-p (model)
    (:documentation "Returns T if the model is a hull, otherwise NIL."))
  (save (model)
    (:documentation "Updates the model in the database or throws an error if it does not exist."))
  (delete (model)
    (:documentation "Deletes the model from the database."))
  (insert (model &key clone)
    (:documentation "Inserts the model into the database.")))

(defmacro with-fields ((&rest field-spec) model &body body)
  "Lets you access fields directly by name. This is similar to with-accessors.
Each field-spec can either be a symbol depicting the variable and field to bind or a list of a symbol
and a string, denoting variable name and field name respectively."
  (let ((vargens (gensym "MODEL")))
    `(let ((,vargens ,model))
       (symbol-macrolet
           ,(loop for field in field-spec 
               for varname = (if (listp field) (first field) field)
               for fieldname = (if (listp field) (second field) (string-downcase (symbol-name field)))
               collect `(,varname (data-model:field ,vargens ,fieldname)))
         ,@body))))

(defmacro with-model (model-spec (collection query &key (skip 0) sort save) &body body)
  "Allows easy access to a single model.
Model-spec can be either just the model variable's name, or a list starting with the model's name,
followed by field specifiers like in with-fields. Query should either be a database query or NIL if
a hull is required. If save is non-NIL, a model-save is executed after the body. The return value
of this is always the last statement in the body, even if save is non-NIL."
  (let* ((returngens (gensym "RETURN"))
         (modelname (if (listp model-spec) (car model-spec) model-spec))
         (modelfields (if (listp model-spec) (cdr model-spec) NIL)))
    (if save (setf body `((let ((,returngens (progn ,@body))) (data-model:save ,modelname) ,returngens))))
    (if modelfields (setf body `((with-fields ,modelfields ,modelname ,@body))))
    `(let ((,modelname ,(if query
                            `(data-model:get-one ,collection ,query :skip ,skip :sort ,sort)
                            `(data-model:hull ,collection))))
       (when ,modelname
         ,@body))))

(defmethod getdf ((model data-model:class) field)
  (data-model:field model field))

(define-interface admin
  (define-panel (name category (&key module (modulevar (gensym "MODULE-")) lquery access-branch menu-icon menu-tooltip) &body body)
    (:type :MACRO)))

(define-interface parser
  (parse (text)
    (:documentation "Parses the given text into HTML format, ready to be outputted.")))
