// 音声管理クラス
class VoiceManager {
  constructor() {
    this.availableVoices = [];
    this.selectedVoice = null;
    this.VOICE_STORAGE_KEY = 'selectedVoiceName';
    this.voiceDisplayElem = null;
    this.voiceModalElem = null;
    this.voiceListElem = null;
    this.initialized = false;
  }

  // 初期化処理
  init(voiceDisplayId = 'voiceDisplay') {
    if (this.initialized) return;
    
    this.voiceDisplayElem = document.getElementById(voiceDisplayId);
    if (!this.voiceDisplayElem) {
      console.error('音声表示要素が見つかりません:', voiceDisplayId);
      return;
    }
    
    // 音声選択モーダルの作成
    this.createVoiceModal();
    
    // 音声リストが読み込まれたら実行
    window.speechSynthesis.onvoiceschanged = () => this.loadVoices();
    
    // 初期化時に一度読み込み試行
    this.loadVoices();
    
    // 音声表示をクリックしたらモーダルを表示
    this.voiceDisplayElem.addEventListener('click', () => this.showVoiceModal());
    
    this.initialized = true;
  }

  // 音声モーダルの作成
  createVoiceModal() {
    // すでに存在する場合は作成しない
    if (document.getElementById('voiceModal')) return;
    
    // モーダル要素の作成
    const modal = document.createElement('div');
    modal.id = 'voiceModal';
    modal.className = 'voice-modal';
    
    // モーダルの内容
    modal.innerHTML = `
      <div class="voice-modal-content">
        <h3>音声を選択</h3>
        <div class="voice-list" id="voiceList"></div>
        <div class="voice-close-btn" id="closeVoiceBtn">×</div>
      </div>
    `;
    
    // bodyに追加
    document.body.appendChild(modal);
    
    // 参照を保存
    this.voiceModalElem = modal;
    this.voiceListElem = document.getElementById('voiceList');
    
    // 閉じるボタンのイベント設定
    document.getElementById('closeVoiceBtn').addEventListener('click', () => this.closeVoiceModal());
    
    // スタイルの追加
    this.addStyles();
  }

  // 必要なスタイルを追加
  addStyles() {
    if (document.getElementById('voice-manager-styles')) return;
    
    const styleElem = document.createElement('style');
    styleElem.id = 'voice-manager-styles';
    styleElem.textContent = `
      .voice-modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7);
        z-index: 1000;
      }
      .voice-modal-content {
        position: relative;
        width: 90%;
        max-width: 400px;
        margin: 30% auto;
        background-color: var(--container-background, #fff);
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
      }
      .voice-list {
        max-height: 300px;
        overflow-y: auto;
        margin: 10px 0;
      }
      .voice-item {
        padding: 10px;
        border-bottom: 1px solid var(--border-color, #ddd);
        cursor: pointer;
      }
      .voice-item:hover, .voice-item.selected {
        background-color: rgba(0, 122, 255, 0.1);
      }
      .voice-close-btn {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 30px;
        height: 30px;
        background-color: var(--container-background, #fff);
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 20px;
        font-weight: bold;
        color: var(--text-color, #333);
        cursor: pointer;
      }
      .voice-display {
        text-align: center;
        font-size: 0.9em;
        color: var(--muted-text-color, #666);
        margin-top: 10px;
        padding: 5px;
        border-top: 1px solid var(--border-color, #ddd);
        cursor: pointer;
      }
    `;
    
    document.head.appendChild(styleElem);
  }

  // 利用可能な音声を読み込む
  loadVoices() {
    const voices = speechSynthesis.getVoices();
    // 日本語の音声のみをフィルタリング
    this.availableVoices = voices.filter(voice => 
      voice.lang.includes('ja') || 
      voice.lang.includes('jp') || 
      voice.name.toLowerCase().includes('ja') || 
      voice.name.toLowerCase().includes('jp')
    );
    
    // ローカルストレージから保存された音声名を取得
    const savedVoiceName = localStorage.getItem(this.VOICE_STORAGE_KEY);
    
    if (savedVoiceName && this.availableVoices.some(v => v.name === savedVoiceName)) {
      // 保存された音声が利用可能な場合はそれを使用
      this.selectedVoice = this.availableVoices.find(v => v.name === savedVoiceName);
    } else {
      // デフォルトは「sayaka」を含む音声、なければ最初の日本語音声
      this.selectedVoice = this.availableVoices.find(v => 
        v.name.toLowerCase().includes('sayaka')
      ) || (this.availableVoices.length > 0 ? this.availableVoices[0] : null);
    }
    
    // 音声表示を更新
    this.updateVoiceDisplay();
    
    // 音声選択リストを更新
    this.updateVoiceList();
  }

  // 音声表示を更新
  updateVoiceDisplay() {
    if (!this.voiceDisplayElem) return;
    
    if (this.selectedVoice) {
      this.voiceDisplayElem.textContent = `声色: ${this.selectedVoice.name}`;
    } else {
      this.voiceDisplayElem.textContent = '声色: 利用可能な日本語音声がありません';
    }
  }

  // 音声選択リストを更新
  updateVoiceList() {
    if (!this.voiceListElem) return;
    
    this.voiceListElem.innerHTML = '';
    
    this.availableVoices.forEach(voice => {
      const item = document.createElement('div');
      item.className = 'voice-item';
      if (this.selectedVoice && voice.name === this.selectedVoice.name) {
        item.classList.add('selected');
      }
      item.textContent = voice.name;
      item.addEventListener('click', () => {
        this.selectedVoice = voice;
        localStorage.setItem(this.VOICE_STORAGE_KEY, voice.name);
        this.updateVoiceDisplay();
        this.closeVoiceModal();
        
        // 選択した音声でテスト発声
        const testUtterance = new SpeechSynthesisUtterance('音声を変更しました');
        testUtterance.voice = this.selectedVoice;
        testUtterance.lang = 'ja-JP';
        window.speechSynthesis.speak(testUtterance);
      });
      this.voiceListElem.appendChild(item);
    });
  }

  // 音声選択モーダルを表示
  showVoiceModal() {
    if (!this.voiceModalElem) return;
    
    this.updateVoiceList();
    this.voiceModalElem.style.display = 'block';
  }

  // 音声選択モーダルを閉じる
  closeVoiceModal() {
    if (!this.voiceModalElem) return;
    
    this.voiceModalElem.style.display = 'none';
  }

  // 音声を取得
  getSelectedVoice() {
    return this.selectedVoice;
  }

  // 音声で発話
  speak(text, options = {}) {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = options.lang || 'ja-JP';
    utterance.rate = options.rate || 1.0;
    utterance.pitch = options.pitch || 1.0;
    
    if (this.selectedVoice) {
      utterance.voice = this.selectedVoice;
    }
    
    window.speechSynthesis.speak(utterance);
    
    return utterance;
  }
}

// グローバルインスタンスを作成
const voiceManager = new VoiceManager();

// エクスポート
window.voiceManager = voiceManager; 