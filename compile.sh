#! /bin/sh

mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
npm i
chmod +x node_modules/webpack/bin/*
NODE_ENV=production node_modules/webpack/bin/webpack.js -p
MIX_ENV=prod mix phoenix.digest

# Custom tasks (like DB migrations)
MIX_ENV=prod mix ecto.migrate

# Finally run the server
PORT=4001 MIX_ENV=prod mix phoenix.server

