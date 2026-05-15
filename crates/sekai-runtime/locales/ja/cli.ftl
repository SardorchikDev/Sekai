cli-about = 最速で最小のAIアシスタント。
cli-no-command-provided = コマンドが指定されていません。
cli-try-onboard = `sekai onboard` を実行してワークスペースを初期化してください。
cli-onboard-about = ワークスペースと設定を初期化
cli-agent-about = AIエージェントループを開始
cli-gateway-about = ゲートウェイサーバー (ウェブフック、ウェブソケット) を管理
cli-acp-about = ACPサーバーを起動 (JSON-RPC 2.0 over stdio)
cli-daemon-about = 長時間実行自動デーモンを開始
cli-service-about = OSサービスライフサイクルを管理 (launchd/systemd ユーザーサービス)
cli-doctor-about = デーモン/スケジューラー/チャネル鮮度の診断を実行
cli-status-about = システムステータスを表示 (詳細)
cli-estop-about = エマージェンシーストップ状態を開始・検査・再開
cli-cron-about = スケジュール済みタスクを設定・管理
cli-models-about = プロバイダーモデルカタログを管理
cli-providers-about = サポートされているAIプロバイダーをリスト表示
cli-channel-about = 通信チャネルを管理
cli-integrations-about = 50以上の統合を参照
cli-skills-about = スキル (ユーザー定義機能) を管理
cli-sop-about = 標準操作手順 (SOP) を管理
cli-migrate-about = 他のエージェントランタイムからデータを移行
cli-auth-about = プロバイダー サブスクリプション認証プロファイルを管理
cli-hardware-about = USBハードウェアを発見・内省
cli-peripheral-about = ハードウェアペリフェラルを管理
cli-memory-about = エージェントメモリエントリを管理
cli-config-about = Sekai設定を管理
cli-update-about = Sekai更新を確認・適用
cli-self-test-about = 診断自己テストを実行
cli-completions-about = シェル補完スクリプトを生成
cli-desktop-about = Sekaiコンパニオンデスクトップアプリを起動
cli-config-schema-about = 完全な設定JSONスキーマをstdoutにダンプ
cli-config-list-about = すべての設定プロパティを現在の値とともにリスト表示
cli-config-get-about = 設定プロパティ値を取得
cli-config-set-about = 設定プロパティを設定 (シークレットフィールドはマスク入力で自動プロンプト)
cli-config-init-about = 未設定セクションをデフォルト (enabled=false) で初期化
cli-config-migrate-about = config.tomlを現在のスキーマバージョンにディスク上で移行 (コメント保持)
cli-service-install-about = 自動開始と再開のためのデーモンサービスユニットをインストール
cli-service-start-about = デーモンサービスを開始
cli-service-stop-about = デーモンサービスを停止
cli-service-restart-about = 最新設定を適用するためデーモンサービスを再開
cli-service-status-about = デーモンサービスステータスを確認
cli-service-uninstall-about = デーモンサービスユニットをアンインストール
cli-service-logs-about = デーモンサービスログをテール表示
cli-channel-list-about = すべての設定済みチャネルをリスト表示
cli-channel-start-about = すべての設定済みチャネルを開始
cli-channel-doctor-about = 設定済みチャネルのヘルスチェックを実行
cli-channel-add-about = 新しいチャネル設定を追加
cli-channel-remove-about = チャネル設定を削除
cli-channel-send-about = 設定済みチャネルに1回限りのメッセージを送信
cli-skills-list-about = すべてのインストール済みスキルをリスト表示
cli-skills-audit-about = スキルソースディレクトリまたはインストール済みスキル名を監査
cli-skills-install-about = URLまたはローカルパスから新しいスキルをインストール
cli-skills-remove-about = インストール済みスキルを削除
cli-skills-test-about = スキル (またはすべてのスキル) の TEST.sh 検証を実行
cli-cron-list-about = すべてのスケジュールタスクを一覧表示
cli-cron-add-about = 新しい定期スケジュールタスクを追加
cli-cron-add-at-about = 特定の UTC タイムスタンプで発火するワンショットタスクを追加
cli-cron-add-every-about = 固定間隔で繰り返すタスクを追加
cli-cron-once-about = 現在から遅延後に発火するワンショットタスクを追加
cli-cron-remove-about = スケジュールタスクを削除
cli-cron-update-about = 既存のスケジュールタスクの 1 つ以上のフィールドを更新
cli-cron-pause-about = スケジュールタスクを一時停止
cli-cron-resume-about = 一時停止したタスクを再開
cli-auth-login-about = OAuth でログイン (OpenAI Codex または Gemini)
cli-auth-refresh-about = リフレッシュトークンを使用して OpenAI Codex アクセストークンをリフレッシュ
cli-auth-logout-about = 認証プロファイルを削除
cli-auth-use-about = プロバイダーのアクティブなプロファイルを設定
cli-auth-list-about = 認証プロファイルを一覧表示
cli-auth-status-about = アクティブなプロファイルとトークン有効期限情報を表示
cli-memory-list-about = オプションのフィルター付きでメモリエントリを一覧表示
cli-memory-get-about = キーで特定のメモリエントリを取得
cli-memory-stats-about = メモリバックエンド統計とヘルスを表示
cli-memory-clear-about = カテゴリ別、キー別、またはすべてをクリアしてメモリをクリア
cli-estop-status-about = 現在の estop ステータスを表示
cli-estop-resume-about = エンゲージされた estop レベルから再開
cli-models-refresh-about = プロバイダーモデルをリフレッシュしてキャッシュ
cli-models-list-about = プロバイダーのキャッシュされたモデルを一覧表示
cli-models-set-about = 設定でデフォルトモデルを設定
cli-models-status-about = 現在のモデル設定とキャッシュステータスを表示
cli-doctor-models-about = プロバイダー全体のモデルカタログをプローブして可用性を報告
cli-doctor-traces-about = ランタイムトレースイベント (ツール診断とモデル応答) をクエリ
cli-hardware-discover-about = USB デバイスを列挙して既知のボードを表示
cli-hardware-introspect-about = デバイスをそのシリアル番号またはデバイスパスで内省
cli-hardware-info-about = ST-Link 経由 probe-rs を使用して USB でチップ情報を取得
cli-peripheral-list-about = 設定されたペリフェラルを一覧表示
cli-peripheral-add-about = ボードタイプとトランスポートパスでペリフェラルを追加
cli-peripheral-flash-about = Arduino ボードに Sekai ファームウェアをフラッシュ
cli-sop-list-about = ロードされた SOP を一覧表示
cli-sop-validate-about = SOP 定義を検証
cli-sop-show-about = SOP の詳細を表示
cli-migrate-openclaw-about = OpenClaw ワークスペースからこの Sekai ワークスペースにメモリをインポート
cli-agent-long-about =
    AI エージェントループを起動します。

    設定された AI プロバイダーでインタラクティブなチャットセッションを起動します。単一ショットクエリの場合は --message を使用し、インタラクティブモードに入りません。

    例:
    sekai agent                              # インタラクティブセッション
    sekai agent -m "Summarize today's logs"  # 単一メッセージ
    sekai agent -p anthropic --model claude-sonnet-4-20250514
    sekai agent --peripheral nucleo-f401re:/dev/ttyACM0
cli-gateway-long-about =
    ゲートウェイサーバー（webhook、websocket）を管理します。

    受信 webhook イベントと WebSocket 接続を受け入れる HTTP/WebSocket ゲートウェイを起動、再起動、または検査します。

    例:
    sekai gateway start              # ゲートウェイを起動
    sekai gateway restart            # ゲートウェイを再起動
    sekai gateway get-paircode       # ペアリングコードを表示
cli-acp-long-about =
    ACP サーバーを起動します（stdio 上の JSON-RPC 2.0）。

    IDE とツール統合用に stdin/stdout で JSON-RPC 2.0 サーバーを起動します。セッション管理と通知としてのストリーミングエージェント応答に対応しています。

    メソッド: initialize、session/new、session/prompt、session/stop。

    例:
    sekai acp                        # ACP サーバーを起動
    sekai acp --max-sessions 5       # 同時セッション数を制限
cli-daemon-long-about =
    長時間実行の自律型デーモンを起動します。

    完全な Sekai ランタイムを起動します: ゲートウェイサーバー、すべての設定されたチャネル（Telegram、Discord、Slack など）、ハートビートモニター、および cron スケジューラー。これは本番環境またはオンアシスタントとして Sekai を実行する推奨方法です。

    デーモンを OS サービス（systemd/launchd）として登録し、ブート時に自動起動するには「sekai service install」を使用してください。

    例:
    sekai daemon                   # 設定デフォルトを使用
    sekai daemon -p 9090           # ポート 9090 のゲートウェイ
    sekai daemon --host 127.0.0.1  # ローカルホストのみ
cli-cron-long-about =
    スケジュール済みタスクを設定および管理します。

    cron 式、RFC 3339 タイムスタンプ、期間、または固定間隔を使用して、定期的、ワンショット、または間隔ベースのタスクをスケジュールします。

    Cron 式は標準 5 フィールド形式を使用します: 「min hour day month weekday」。タイムゾーンはデフォルトで UTC です。--tz と IANA タイムゾーン名で上書きしてください。

    例:
    sekai cron list
    sekai cron add '0 9 * * 1-5' 'Good morning' --tz America/New_York --agent
    sekai cron add '*/30 * * * *' 'Check system health' --agent
    sekai cron add '*/5 * * * *' 'echo ok'
    sekai cron add-at 2025-01-15T14:00:00Z 'Send reminder' --agent
    sekai cron add-every 60000 'Ping heartbeat'
    sekai cron once 30m 'Run backup in 30 minutes' --agent
    sekai cron pause TASK_ID
    sekai cron update TASK_ID --expression '0 8 * * *' --tz Europe/London
cli-channel-long-about =
    通信チャネルを管理します。

    Sekai をメッセージングプラットフォームに接続するチャネルを追加、削除、一覧表示、送信、およびヘルスチェックします。サポートされるチャネルタイプ: telegram、discord、slack、whatsapp、matrix、imessage、email。

    例:
    sekai channel list
    sekai channel doctor
    sekai channel add telegram '{ "{" }"bot_token":"..."、"name":"my-bot"{ "}" }'
    sekai channel remove my-bot
    sekai channel bind-telegram sekai_user
    sekai channel send 'Alert!' --channel-id telegram --recipient 123456789
cli-hardware-long-about =
    USB ハードウェアを検出して内省します。

    接続されている USB デバイスを列挙し、既知の開発ボード（STM32 Nucleo、Arduino、ESP32）を特定し、probe-rs/ST-Link 経由でチップ情報を取得します。

    例:
    sekai hardware discover
    sekai hardware introspect /dev/ttyACM0
    sekai hardware info --chip STM32F401RETx
cli-peripheral-long-about =
    ハードウェアペリフェラルを管理します。

    エージェントにツール（GPIO、センサー、アクチュエーター）を公開するハードウェアボードを追加、一覧表示、フラッシュ、および設定します。サポートされるボード: nucleo-f401re、rpi-gpio、esp32、arduino-uno。

    例:
    sekai peripheral list
    sekai peripheral add nucleo-f401re /dev/ttyACM0
    sekai peripheral add rpi-gpio native
    sekai peripheral flash --port /dev/cu.usbmodem12345
    sekai peripheral flash-nucleo
cli-memory-long-about =
    エージェントメモリエントリを管理します。

    エージェントが保存したメモリエントリを一覧表示、検査、クリアします。カテゴリとセッション別のフィルタリング、ページネーション、および確認付きバッククリアをサポートしています。

    例:
    sekai memory stats
    sekai memory list
    sekai memory list --category core --limit 10
    sekai memory get KEY
    sekai memory clear --category conversation --yes
cli-config-long-about =
    Sekai 設定を管理します。

    ドット記法で設定プロパティを表示、設定、または初期化します。「schema」を使用して、設定ファイルの完全な JSON スキーマをダンプします。

    プロパティはドット記法でアドレス指定されます（例: channels.matrix.mention-only）。
    シークレットフィールド（API キー、トークン）は自動的にマスクされた入力を使用します。
    列挙フィールドは、値が省略された場合、インタラクティブ選択を提供します。

    例:
    sekai config list                                  # すべてのプロパティを一覧表示
    sekai config list --secrets                        # シークレットのみを一覧表示
    sekai config list --filter channels.matrix         # プレフィックスでフィルタリング
    sekai config get channels.matrix.mention-only      # 値を取得
    sekai config set channels.matrix.mention-only true # 値を設定
    sekai config set channels.matrix.access-token      # シークレット: マスクされた入力
    sekai config set channels.matrix.stream-mode       # 列挙: インタラクティブ選択
    sekai config init channels.matrix                  # デフォルト値でセクションを初期化
    sekai config schema                                # JSON Schema を stdout に出力
    sekai config schema > schema.json

    プロパティパスタブ補完は `sekai completions <shell>` に自動的に含まれます。
cli-update-long-about =
    Sekai 更新を確認して適用します。

    デフォルトでは、6 段階のパイプライン（プリフライト、ダウンロード、バックアップ、検証、スワップ、スモークテスト）で最新リリースをダウンロードしてインストールします。失敗時に自動ロールバックします。

    更新を確認するだけでインストールしない場合は --check を使用してください。
    インストール確認プロンプトをスキップするには --force を使用してください。
    最新ではなく特定のリリースをターゲットにするには --version を使用してください。

    例:
    sekai update                      # 最新をダウンロードしてインストール
    sekai update --check              # チェックのみ、インストールしない
    sekai update --force              # 確認なしでインストール
    sekai update --version 0.6.0      # 特定のバージョンをインストール
cli-self-test-long-about =
    診断自己テストを実行して Sekai インストールを検証します。

    デフォルトでは、ネットワークチェック（ゲートウェイヘルス、メモリラウンドトリップ）を含む完全なテストスイートを実行します。--quick を使用して、ネットワークチェックをスキップしてより高速なオフライン検証を実行してください。

    例:
    sekai self-test             # 完全なスイート
    sekai self-test --quick     # 高速チェックのみ（ネットワークなし）
cli-completions-long-about =
    `sekai` のシェル補完スクリプトを生成します。

    スクリプトは stdout に出力されるため、直接ソースできます:

    例:
    source <(sekai completions bash)
    sekai completions zsh > ~/.zfunc/_sekai
    sekai completions fish > ~/.config/fish/completions/sekai.fish
cli-desktop-long-about =
    Sekai コンパニオンデスクトップアプリを起動します。

    コンパニオンアプリは、CLI と同じゲートウェイに接続する軽量のメニューバー/システムトレイアプリケーションです。ダッシュボードへのクイックアクセス、ステータス監視、およびデバイスペアリングを提供します。

    --install を使用して、プラットフォーム用の事前ビルドコンパニオンアプリをダウンロードしてください。

    例:
    sekai desktop              # コンパニオンアプリを起動
    sekai desktop --install    # ダウンロードしてインストール
