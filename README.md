# jray

[![build](https://github.com/michurin/jray/actions/workflows/ci.yaml/badge.svg)](https://github.com/michurin/jray/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/michurin/jray/graph/badge.svg?token=HSQJS6AQFZ)](https://codecov.io/gh/michurin/jray)

`jray` is a CLI utility for "X-ray" inspection of JSON data.

Like an X-ray, it lets you see through complex, deeply nested,
or even malformed structures by flattening them into
a clear list of `.path=value` pairs.
This makes the data easy to read, search, and include in bug reports.

`jray` applies a set of heuristics to extract as much useful
information as possible where conventional tools fail.

It automatically unpack common embedded encodings and formats,
including timestamps, strings that contain JSON, and Base64-encoded JSON-data.
See examples and details below.

Use cases:

* debugging and inspecting JSON
* analyzing malformed or partially valid data
* preparing clear and actionable bug reports
* exploring unknown or complex JSON structures

`jray` — when you don’t just want to read JSON, but see right through it.

## Help message

```
jray [-c] [-s] [-h] <in.json >out.txt
  -c force colored output
  -s shallow output (do not dive into JSON-strings)
  -h help message
```

## Examples and demos

Real output is colored.

### It does the trick

```sh
echo '{"K":"V","A":[1,2,{"e":true}]}' | jray
```

```
.K = V (string)
.A[0] = 1 (float)
.A[1] = 2 (float)
.A[2].e = true (bool)
```

### It is error-tolerant

```sh
echo '{"A":[1,{"q":[2' | jray
```

```
.A[0] = 1 (float)
.A[1].q[0] = 2 (float)
.A[1].q[1]: [array] Unexpected EOF
```

In some cases it shows context of error:

```sh
echo '{"data":{"key-a":"a","key-b":***}}' | jray
```

```
.data.["key-a"] = a (string)
.data.["key-b"]: [value] Parse error: ("key-a":"a","key-b":***}}\n) invalid character '*' looking for beginning of value
```

### It supports multiple JSON objects

```sh
echo '{"X":1} {"X":2} {"X":3}' | jray
```

```
.X = 1 (float)
---
.X = 2 (float)
---
.X = 3 (float)
```

### It supports embedded JSONs

```sh
echo '{"A":false,"B":"{\"x\":[1,2],\"y\":true}","C":"just str"}' | jray
```

```
.A = false (bool)
.B | .x[0] = 1 (float)
.B | .x[1] = 2 (float)
.B | .y = true (bool)
.C = just str (string)
```

### It supports embedded base64 JSONs

```sh
echo '[1,2,3]' | openssl enc -base64 # WzEsMiwzXQo=
echo '{"A":"B","V":"WzEsMiwzXQo="}' | jray
```

```
.A = B
.V # .[0] = 1 (float)
.V # .[1] = 2 (float)
.V # .[2] = 3 (float)
```

### Supports timestamps in seconds and milliseconds

```sh
echo '[1777777777, 1777777777777]' | jray
```

```
.[0] = 1777777777 (2026-05-03 03:09:37 UTC) (float/timestamp)
.[1] = 1777777777777 (2026-05-03 03:09:37.777 UTC) (float/timestamp)
```

### Supports UUIDv7

```sh
echo '{"id": "019ddddd-dddd-7ddd-0123-456789abcdef"}' | jray
```

```
.id = 019ddddd-dddd-7ddd-0123-456789abcdef (2026-04-30 10:09:58.237 UTC) (string/UUIDv7)
```

### Supports non-unique keys

```sh
echo '{"A":"a","A":"b"}' | jray
```

```
.A = a (string)
.A = b (string)
```

## Install it and enjoy

```sh
go install github.com/michurin/jray@latest
```

## Links

- [Reddit: One more tool for JSON inspection](https://www.reddit.com/r/json/comments/1t2cz9e/one_more_tool_for_json_inspection/)
