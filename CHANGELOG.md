# CHANGELOG

## main

## v0.3.1

- Move Public Apple Certificate to jws_validation directory.

## v0.3.0

- Add JWSValidation module to validate Apple's JSON Web Signature (JWS).

## v0.2.1

- Remove unecessary slash from get_transaction_info call.

## v0.2.0

- Remove `nanoid` dependency.
- Added the `AppStore.Token` for token generation.
- Require Elixir 1.15, support Elixir 1.17 and OTP 27.
- Added a call to GET transaction info by transaction ID `AppStore.API.TransactionInfo` (#5)

## v0.1.0

Initial release
