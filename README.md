# StrictObject.js

自動でvalidateしてくれるStrictなObjectを作ります。

セットしようとした値が正しいかどうかチェックし、不正な値であれば無視します。

## 要件

* `Object.defineProperty`が実装されている環境

## 使い方

  newする際、第一引数に定義を渡します

	new StrictObject({/* DEFINITION */});

  例えば、以下のように定義します

```js
var user = new StrictObject({
  name: { type: String, default: 'anonymous' },
  mail: { type: /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/ },
  login: { type: Number, default: 0 },
  last: { type: Date, default: Date.now() },
  type: { type: ['open', 'public', 'private'], default: 'open' }
});
```

  値をセットします

	user.name = 'geta6'

  値を参照します

	console.log(user.name); // 'geta6'

  続けて、不正な値をセットします

	user.name = 12345

  値を参照します

	console.log(user.name); // 'geta6'

  `type: String`とあるので、Number型の`12345`は正しく無視されます

## DEFINITION

key        | default  | val
-----------|----------|-----
type       | null     | 正規表現、候補を列記した配列、型の名前を受け付けます(`String`・`Number`・`Array`・`Self-Definition`)
default    | null     | デフォルト値を設定します
writable   | true     | `false`にすると、デフォルト値セット以降の変更を受け付けなくなります
enumerable | true     | `false`にすると、`StrictObject.get()`した際に、その値を非表示にします
validate   | function | 値を第一引数・キーを第二引数に取り、返り値に`Boolean`を期待します、`false`なら必ず無視します

`type -> validate`の順番でチェックします

## Method

#### `StrictObject.get([key])`

`key`に相当する値を返します。
無引数で実行すると、全ての値を含むオブジェクトを返します。
`enumerable`が`false`に設定されていると表示されません。

#### `StrictObject.set(key, [val])`

`key`は必須です。
`key`に`val`をセットします。
`val`無しで実行するとデフォルト値か、デフォルト値がなければ`null`をセットします。

`StrictObject.propertyName = 'hoge'`のように、通常通りの操作でアクセス可能です。

## Example

```coffee
so = new StrictObject
  style:
    type: ['view', 'json', 'feed']
    default: 'view'
    writable: no
  query:
    type: String
    validate: (val) ->
      return /^[A-Za-z0-9\s]*$/.test val
  start:
    type: Number
    default: 0
  limit:
    type: Number
    default: 50
  order:
    type: ['name', 'date', 'view', 'star', 'cmnt', 'rate']
    default: 'date'
  mtype:
    type: String
  mtime:
    type: /[0-9]+(hour|day|week|month|year)/
    default: null
  fonly:
    type: Boolean
    default: yes
  hides:
    type: null
    enumerable: no
    default: 'free hidden form'

so.style = 'json'           # Valid but NOT writable
so.style = 'hoge'           # Invalid
so.query = 234              # Invalid
so.query = '234'            # Valid
so.query = './../../../etc' # Invalid (validate function)
so.mtime = '1hour'          # Valid
so.mtime = '1minutes'       # Invalid

console.log so.get()
console.log '>>', so.hides

###
{ style: 'view',
  query: '234',
  start: 0,
  limit: 50,
  order: 'date',
  mtype: null,
  mtime: '1hour',
  fonly: true }
>> free hidden form
###
```
