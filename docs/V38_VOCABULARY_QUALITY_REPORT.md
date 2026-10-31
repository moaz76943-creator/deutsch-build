# v38 Vocabulary Quality Report

## Current dataset
- Bundled ContentItem entries: 500
- Duplicate German headwords: 0
- Clearly generic examples detected before revision: 201
- Generic examples revised: 201
- Explicit plural correction: `die Ferien` → `Das sind die Ferien.`

## Important limitation
The requested additional 9,500 German-Arabic entries have **not** been inserted as if they were verified. A web-discovered `de_10000.csv` source was inspected and rejected because its entries contain synthetic/garbled compounds (for example combinations such as `SchmalHoffnung`), which would lower the quality of the app. The app therefore does not claim to contain 10,000 validated German-Arabic entries yet.
