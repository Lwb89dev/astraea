# Astraea — audit sicurezza e privacy

Data: 19 luglio 2026

## Esito sintetico

Il modello crittografico di base è sensato: contenuto degli eventi cifrato con
NIP-44 v2, chiave privata in secure storage o delegata ad Amber, soli relay
`wss://`, backup Android disabilitato e export autenticato AES-256-GCM. I vettori
ufficiali NIP-44 passano.

Dopo i fix di questo audit, analisi statica, test e build Android di debug sono
puliti. Le build release non possono più ricadere sulla firma debug e falliscono
esplicitamente finché non viene configurata la chiave dedicata. L'app non è però
pronta per la pubblicazione finché non viene scelto l'application ID definitivo
e fornita la relativa configurazione di firma.

## Correzioni applicate

### Alte

- **REQ inviate a relay fuori scope.** In `dart_nostr 10.0.1`, il convenience
  method async usato dall'app perdeva il filtro `relays` quando creava la
  subscription e terminava al primo EOSE. Dopo una lettura metadata, una query
  calendario poteva raggiungere anche relay non scelti. Astraea ora usa la API
  stream con lista esplicita, attende tutti gli EOSE, applica timeout/cap e
  chiude sempre subscription e listener.
- **Eventi relay non autenticati.** Le risposte kind 0 e kind 30078 ora devono
  avere autore/kind attesi, ID ricalcolato NIP-01 e firma Schnorr valida. Per gli
  eventi calendario viene verificata anche la corrispondenza tra `d` tag e ID
  cifrato. Anche la risposta firmata da Amber deve coincidere byte-per-byte con
  la richiesta.
- **Tombstone cancellata dalla stessa NIP-09.** La delete pubblicava la tombstone
  e poi cancellava la coordinata e il nuovo ID, potendo rendere invisibile la
  cancellazione agli altri device. Ora la NIP-09 riferisce solo la versione
  concreta precedente e lascia disponibile la tombstone cifrata.
- **Contaminazione fra account.** Gli eventi memorizzano il pubkey proprietario
  della sync. Un evento appartenente a un account non viene pubblicato con un
  altro account; gli eventi legacy già sincronizzati sono migrati al login.
- **Ack incompleti.** Un evento era marcato sincronizzato dopo il primo OK.
  Adesso ogni relay configurato, incluso l'home relay, deve confermare; i
  successi parziali restano idempotenti e vengono ritentati.

### Medie/basse

- Rimosso `relay.nostr.band` sia dai relay sync predefiniti sia dai fallback
  metadata.
- Il timestamp di update è monotono al secondo, evitando collisioni fra due
  edit rapidi di un evento replaceable.
- L'nsec è mostrato con `FLAG_SECURE`, copiato come contenuto sensibile e
  rimosso dalla clipboard dopo 60 secondi.
- Download avatar limitato a HTTPS anche dopo redirect, MIME `image/*`, 5 MiB e
  timeout; gli eventi profilo sono autenticati prima del fetch.
- Cleartext Android disabilitato esplicitamente; notifiche marcate private;
  eliminato il permesso duplicato `USE_EXACT_ALARM`.
- Deep link dei widget costruiti con escaping dei query parameter.
- Ricorrenze vecchie non consumano più migliaia di iterazioni e il mensile al
  giorno 31 non deriva permanentemente dopo febbraio.
- Widget: dimensione rilevata secondo l'orientamento, scala reattiva a entrambi
  gli assi, righe mensili proporzionate allo spazio e navigazione indipendente
  giorno/settimana/mese tramite frecce.
- Onboarding in tre passaggi come Echoes, con relay scelti esplicitamente e
  `nos.lol` / `relay.damus.io` soltanto proposti; gli upgrade conservano la
  precedente configurazione implicita senza sovrascrivere una scelta vuota.
- Cancellazioni monotone al secondo, proprietario sync conservato negli edit e
  blocco della pubblicazione accidentale di eventi appartenenti a un altro
  account.
- Calendario mensile ottimizzato: le ricorrenze visibili vengono espanse una
  sola volta per finestra anziché una volta per ciascuna delle 42 celle.

## Rischi residui prioritizzati

### P0 — blocca la distribuzione

1. **Identità Android definitiva.** `applicationId` è ancora il valore di
   sviluppo `com.example.epochs`. Prima di distribuire: scegliere un namespace
   posseduto e verificare l'upgrade path. La build ora richiede una keystore
   release esplicita tramite `android/key.properties` e non usa più la debug.

### P1 — hardening raccomandato

1. **Dati locali in chiaro.** Hive e la cache Home Widget contengono titoli,
   descrizioni, luoghi e orari non cifrati a livello applicativo. Sandbox,
   file-based encryption Android e `allowBackup=false` riducono il rischio, ma
   root, exploit del device o acquisizione forense a device sbloccato possono
   leggerli. Valutare Hive cifrato con chiave Keystore e migrazione atomica. Il
   widget, per natura, espone inoltre i titoli al launcher.
2. **Nessun app lock.** Chi ha accesso al telefono sbloccato vede il calendario.
   Valutare blocco biometrico/PIN e un'opzione globale anti-screenshot; oggi
   `FLAG_SECURE` protegge soltanto la schermata nsec.
3. **Metadata Nostr.** NIP-44 nasconde il contenuto, non pubkey, IP, relay scelti,
   kind, timestamp, quantità di eventi, frequenza update e `d` tag. È un limite
   del protocollo/modello di utilizzo, da dichiarare nella privacy policy.
   Home relay/Tor/VPN possono ridurre correlazione e retention presso relay
   pubblici.
4. **Sync Amber intenzionalmente manuale.** Le sessioni con chiave locale fanno
   una sync all'apertura; Amber resta manuale per non aprire il signer o
   moltiplicare prompt di decrypt senza un gesto esplicito.
5. **Web non hardenizzato per produzione.** Mancano una CSP esplicita, un threat
   model per IndexedDB/browser extensions e parità dei controlli Android. Fino a
   un audit dedicato, considerare Android la piattaforma supportata per dati
   sensibili.
6. **Gestione file import.** Il picker carica l'intero ICS/JSON in memoria prima
   del parsing. Un file enorme scelto dall'utente può causare memory pressure;
   passare a lettura streaming e limite dimensione.

### P2 — manutenzione

- `flutter pub outdated` segnala 10 dipendenze vincolate sotto una versione
  risolvibile recente (fra cui notifications, timezone, home_widget e
  file_picker) e 2 aggiornamenti compatibili bloccati nel lockfile. Gli upgrade
  major vanno pianificati e testati, non inseriti nel check di release.
- La build avverte che `amberflutter`, `flutter_timezone` e `home_widget`
  applicano ancora Kotlin Gradle Plugin; una futura versione Flutter interromperà
  la build se i plugin non migrano a Built-in Kotlin.
- Mancano test Android strumentati per resize/navigation dei RemoteViews e test
  di integrazione con relay ostile/lento, più relay discordanti e Amber reale.

## Controlli positivi confermati

- NIP-44 v2 con nonce CSPRNG, MAC constant-time, limiti/padding e vettori
  canonici validi/invalidi.
- Export: PBKDF2-HMAC-SHA256 (210.000 iterazioni) + AES-256-GCM con sale e nonce
  casuali.
- Chiave privata non nei log/SharedPreferences; input nsec senza suggerimenti o
  autocorrect; Amber mantiene la chiave fuori dal processo.
- `allowBackup=false`, componenti sensibili non esportati, RemoteViewsService
  protetto da `BIND_REMOTEVIEWS`, PendingIntent espliciti e deep-link allowlist.
- Relay UI limitati a `wss://`, validazione ripetuta al boundary di rete,
  pubblicazioni indirizzate solo alla lista sync.
- Nessuna chiave/segreto reale trovato nel repository; le chiavi nella fixture
  sono vettori pubblici di test.

## Verifiche eseguite

- `flutter analyze`: nessun problema.
- `flutter test`: 78 test superati.
- `flutter build apk --debug`: completata.
- `flutter pub get --enforce-lockfile`: hash lockfile validi, nessun advisory
  mostrato dal resolver Pub.
- Ricerca statica di secret, cleartext URL, componenti esportati, logging,
  storage, clipboard, file/network input, PendingIntent e permessi.

Questa revisione statica non sostituisce pentest su device, review della supply
chain nativa, test dinamici MITM/relay né una verifica crittografica formale.

Riferimenti: [Dart security advisories](https://dart.dev/tools/pub/security-advisories),
[Android secure clipboard](https://developer.android.com/privacy-and-security/risks/secure-clipboard-handling),
[Android FLAG_SECURE](https://developer.android.com/security/fraud-prevention/activities),
[Android broadcast security](https://developer.android.com/develop/background-work/background-tasks/broadcasts).
