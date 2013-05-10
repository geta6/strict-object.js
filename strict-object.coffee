class StrictObject

  _object = {}
  _schema = {}
  _is = (name, object) ->
    return (Object.prototype.toString.call object) is "[object #{name}]"

  constructor: (schema = {}) ->
    _schema = schema

    for key, val of _schema
      unless _schema[key].hasOwnProperty 'default'
        val.default = _schema[key].default = null
      unless _schema[key].hasOwnProperty 'writable'
        val.writable = _schema[key].writable = yes
      unless _schema[key].hasOwnProperty 'validate'
        val.validate = _schema[key].validate = (-> yes)
      unless _schema[key].hasOwnProperty 'enumerable'
        val.enumerable = _schema[key].enumerable = yes
      do (key, val) =>
        Object.defineProperty @, key,
          enumerable: val.enumerable
          configurable: no
          get: => return @get key
          set: (value) => return @set key, value
      @set key, val.default

  set: (key, val = null) ->
    if !_schema[key].writable and _object.hasOwnProperty key
      return _object[key]

    if val is null
      return _object[key] = _schema[key].default

    settable = no

    if _schema[key].type is null
      settable = yes
    else if _is 'Array', _schema[key].type
      if -1 < _schema[key].type.indexOf val
        settable = yes
    else if _is 'RegExp', _schema[key].type
      if _schema[key].type.test val
        settable = yes
    else if _is 'Function', _schema[key].type
      if val is _schema[key].type val
        settable = yes
      if val instanceof _schema[key].type
        settable = yes

    if settable and _schema[key].validate
      settable = _schema[key].validate val, key

    _object[key] = val if settable
    return _object[key]

  get: (key = null) ->
    return _object[key] if key
    object = {}
    for key, val of _object
      if _schema[key].enumerable is yes
        object[key] = val
    return object
