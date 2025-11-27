// Textos multiidioma
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String languageCode) {
    return AppLocalizations(languageCode);
  }

  // Helper method para obtener traducciones
  String _translate(Map<String, String> translations) {
    return translations[languageCode] ?? translations['en'] ?? '';
  }

  // Textos generales
  String get appName => 'SafeWalk';

  String get welcome => _translate({
    'es': 'Bienvenido',
    'en': 'Welcome',
    'zh': '欢迎',
    'de': 'Willkommen',
    'ja': 'ようこそ',
    'ko': '환영합니다',
    'th': 'ยินดีต้อนรับ',
    'pt': 'Bem-vindo',
    'fr': 'Bienvenue',
  });

  String get settings => _translate({
    'es': 'Ajustes',
    'en': 'Settings',
    'zh': '设置',
    'de': 'Einstellungen',
    'ja': '設定',
    'ko': '설정',
    'th': 'การตั้งค่า',
    'pt': 'Configurações',
    'fr': 'Paramètres',
  });

  String get account => _translate({
    'es': 'Cuenta',
    'en': 'Account',
    'zh': '账户',
    'de': 'Konto',
    'ja': 'アカウント',
    'ko': '계정',
    'th': 'บัญชี',
    'pt': 'Conta',
    'fr': 'Compte',
  });

  String get cancel => _translate({
    'es': 'Cancelar',
    'en': 'Cancel',
    'zh': '取消',
    'de': 'Abbrechen',
    'ja': 'キャンセル',
    'ko': '취소',
    'th': 'ยกเลิก',
    'pt': 'Cancelar',
    'fr': 'Annuler',
  });

  String get save => _translate({
    'es': 'Guardar',
    'en': 'Save',
    'zh': '保存',
    'de': 'Speichern',
    'ja': '保存',
    'ko': '저장',
    'th': 'บันทึก',
    'pt': 'Salvar',
    'fr': 'Enregistrer',
  });

  String get delete => _translate({
    'es': 'Eliminar',
    'en': 'Delete',
    'zh': '删除',
    'de': 'Löschen',
    'ja': '削除',
    'ko': '삭제',
    'th': 'ลบ',
    'pt': 'Excluir',
    'fr': 'Supprimer',
  });

  String get update => _translate({
    'es': 'Actualizar',
    'en': 'Update',
    'zh': '更新',
    'de': 'Aktualisieren',
    'ja': '更新',
    'ko': '업데이트',
    'th': 'อัปเดต',
    'pt': 'Atualizar',
    'fr': 'Mettre à jour',
  });

  String get continue_ => _translate({
    'es': 'Continuar',
    'en': 'Continue',
    'zh': '继续',
    'de': 'Fortfahren',
    'ja': '続ける',
    'ko': '계속',
    'th': 'ดำเนินการต่อ',
    'pt': 'Continuar',
    'fr': 'Continuer',
  });

  String get back => _translate({
    'es': 'Volver',
    'en': 'Back',
    'zh': '返回',
    'de': 'Zurück',
    'ja': '戻る',
    'ko': '뒤로',
    'th': 'กลับ',
    'pt': 'Voltar',
    'fr': 'Retour',
  });

  // Autenticación
  String get login => _translate({
    'es': 'Iniciar Sesión',
    'en': 'Login',
    'zh': '登录',
    'de': 'Anmelden',
    'ja': 'ログイン',
    'ko': '로그인',
    'th': 'เข้าสู่ระบบ',
    'pt': 'Entrar',
    'fr': 'Connexion',
  });

  String get register => _translate({
    'es': 'Registrarse',
    'en': 'Register',
    'zh': '注册',
    'de': 'Registrieren',
    'ja': '登録',
    'ko': '등록',
    'th': 'ลงทะเบียน',
    'pt': 'Registrar',
    'fr': 'S\'inscrire',
  });

  String get logout => _translate({
    'es': 'Cerrar Sesión',
    'en': 'Logout',
    'zh': '登出',
    'de': 'Abmelden',
    'ja': 'ログアウト',
    'ko': '로그아웃',
    'th': 'ออกจากระบบ',
    'pt': 'Sair',
    'fr': 'Déconnexion',
  });

  String get email => _translate({
    'es': 'Correo Electrónico',
    'en': 'Email',
    'zh': '电子邮件',
    'de': 'E-Mail',
    'ja': 'メール',
    'ko': '이메일',
    'th': 'อีเมล',
    'pt': 'E-mail',
    'fr': 'E-mail',
  });

  String get password => _translate({
    'es': 'Contraseña',
    'en': 'Password',
    'zh': '密码',
    'de': 'Passwort',
    'ja': 'パスワード',
    'ko': '비밀번호',
    'th': 'รหัสผ่าน',
    'pt': 'Senha',
    'fr': 'Mot de passe',
  });

  String get forgotPassword => _translate({
    'es': '¿Olvidaste tu contraseña?',
    'en': 'Forgot password?',
    'zh': '忘记密码？',
    'de': 'Passwort vergessen?',
    'ja': 'パスワードを忘れた？',
    'ko': '비밀번호를 잊으셨나요?',
    'th': 'ลืมรหัสผ่าน?',
    'pt': 'Esqueceu a senha?',
    'fr': 'Mot de passe oublié?',
  });

  // Cuenta
  String get editProfile => _translate({
    'es': 'Editar perfil',
    'en': 'Edit profile',
    'zh': '编辑个人资料',
    'de': 'Profil bearbeiten',
    'ja': 'プロフィールを編集',
    'ko': '프로필 편집',
    'th': 'แก้ไขโปรไฟล์',
    'pt': 'Editar perfil',
    'fr': 'Modifier le profil',
  });

  String get changePassword => _translate({
    'es': 'Cambiar contraseña',
    'en': 'Change password',
    'zh': '更改密码',
    'de': 'Passwort ändern',
    'ja': 'パスワードを変更',
    'ko': '비밀번호 변경',
    'th': 'เปลี่ยนรหัสผ่าน',
    'pt': 'Alterar senha',
    'fr': 'Changer le mot de passe',
  });

  String get deleteAccount => _translate({
    'es': 'Eliminar cuenta',
    'en': 'Delete account',
    'zh': '删除账户',
    'de': 'Konto löschen',
    'ja': 'アカウントを削除',
    'ko': '계정 삭제',
    'th': 'ลบบัญชี',
    'pt': 'Excluir conta',
    'fr': 'Supprimer le compte',
  });

  String get currentPassword => _translate({
    'es': 'Contraseña actual',
    'en': 'Current password',
    'zh': '当前密码',
    'de': 'Aktuelles Passwort',
    'ja': '現在のパスワード',
    'ko': '현재 비밀번호',
    'th': 'รหัสผ่านปัจจุบัน',
    'pt': 'Senha atual',
    'fr': 'Mot de passe actuel',
  });

  String get newPassword => _translate({
    'es': 'Nueva contraseña',
    'en': 'New password',
    'zh': '新密码',
    'de': 'Neues Passwort',
    'ja': '新しいパスワード',
    'ko': '새 비밀번호',
    'th': 'รหัสผ่านใหม่',
    'pt': 'Nova senha',
    'fr': 'Nouveau mot de passe',
  });

  String get confirmPassword => _translate({
    'es': 'Confirmar contraseña',
    'en': 'Confirm password',
    'zh': '确认密码',
    'de': 'Passwort bestätigen',
    'ja': 'パスワードを確認',
    'ko': '비밀번호 확인',
    'th': 'ยืนยันรหัสผ่าน',
    'pt': 'Confirmar senha',
    'fr': 'Confirmer le mot de passe',
  });

  // Configuración
  String get language => _translate({
    'es': 'Idioma',
    'en': 'Language',
    'zh': '语言',
    'de': 'Sprache',
    'ja': '言語',
    'ko': '언어',
    'th': 'ภาษา',
    'pt': 'Idioma',
    'fr': 'Langue',
  });

  String get selectLanguage => _translate({
    'es': 'Seleccionar idioma',
    'en': 'Select language',
    'zh': '选择语言',
    'de': 'Sprache wählen',
    'ja': '言語を選択',
    'ko': '언어 선택',
    'th': 'เลือกภาษา',
    'pt': 'Selecionar idioma',
    'fr': 'Sélectionner la langue',
  });

  // Nombres de idiomas
  String get spanish => _translate({
    'es': 'Español',
    'en': 'Spanish',
    'zh': '西班牙语',
    'de': 'Spanisch',
    'ja': 'スペイン語',
    'ko': '스페인어',
    'th': 'ภาษาสเปน',
    'pt': 'Espanhol',
    'fr': 'Espagnol',
  });

  String get english => _translate({
    'es': 'Inglés',
    'en': 'English',
    'zh': '英语',
    'de': 'Englisch',
    'ja': '英語',
    'ko': '영어',
    'th': 'ภาษาอังกฤษ',
    'pt': 'Inglês',
    'fr': 'Anglais',
  });

  String get chinese => _translate({
    'es': 'Chino',
    'en': 'Chinese',
    'zh': '中文',
    'de': 'Chinesisch',
    'ja': '中国語',
    'ko': '중국어',
    'th': 'ภาษาจีน',
    'pt': 'Chinês',
    'fr': 'Chinois',
  });

  String get german => _translate({
    'es': 'Alemán',
    'en': 'German',
    'zh': '德语',
    'de': 'Deutsch',
    'ja': 'ドイツ語',
    'ko': '독일어',
    'th': 'ภาษาเยอรมัน',
    'pt': 'Alemão',
    'fr': 'Allemand',
  });

  String get japanese => _translate({
    'es': 'Japonés',
    'en': 'Japanese',
    'zh': '日语',
    'de': 'Japanisch',
    'ja': '日本語',
    'ko': '일본어',
    'th': 'ภาษาญี่ปุ่น',
    'pt': 'Japonês',
    'fr': 'Japonais',
  });

  String get korean => _translate({
    'es': 'Coreano',
    'en': 'Korean',
    'zh': '韩语',
    'de': 'Koreanisch',
    'ja': '韓国語',
    'ko': '한국어',
    'th': 'ภาษาเกาหลี',
    'pt': 'Coreano',
    'fr': 'Coréen',
  });

  String get thai => _translate({
    'es': 'Tailandés',
    'en': 'Thai',
    'zh': '泰语',
    'de': 'Thailändisch',
    'ja': 'タイ語',
    'ko': '태국어',
    'th': 'ภาษาไทย',
    'pt': 'Tailandês',
    'fr': 'Thaï',
  });

  String get portuguese => _translate({
    'es': 'Portugués',
    'en': 'Portuguese',
    'zh': '葡萄牙语',
    'de': 'Portugiesisch',
    'ja': 'ポルトガル語',
    'ko': '포르투갈어',
    'th': 'ภาษาโปรตุเกส',
    'pt': 'Português',
    'fr': 'Portugais',
  });

  String get french => _translate({
    'es': 'Francés',
    'en': 'French',
    'zh': '法语',
    'de': 'Französisch',
    'ja': 'フランス語',
    'ko': '프랑스어',
    'th': 'ภาษาฝรั่งเศส',
    'pt': 'Francês',
    'fr': 'Français',
  });

  String get darkMode => _translate({
    'es': 'Modo Oscuro',
    'en': 'Dark Mode',
    'zh': '深色模式',
    'de': 'Dunkler Modus',
    'ja': 'ダークモード',
    'ko': '다크 모드',
    'th': 'โหมดมืด',
    'pt': 'Modo Escuro',
    'fr': 'Mode sombre',
  });

  String get notifications => _translate({
    'es': 'Notificaciones',
    'en': 'Notifications',
    'zh': '通知',
    'de': 'Benachrichtigungen',
    'ja': '通知',
    'ko': '알림',
    'th': 'การแจ้งเตือน',
    'pt': 'Notificações',
    'fr': 'Notifications',
  });

  // Alertas
  String get alerts => _translate({
    'es': 'Alertas',
    'en': 'Alerts',
    'zh': '警报',
    'de': 'Warnungen',
    'ja': 'アラート',
    'ko': '알림',
    'th': 'การแจ้งเตือน',
    'pt': 'Alertas',
    'fr': 'Alertes',
  });

  String get obstacleAlerts => _translate({
    'es': 'Alertas de Obstáculos',
    'en': 'Obstacle Alerts',
    'zh': '障碍物警报',
    'de': 'Hinderniswarnungen',
    'ja': '障害物アラート',
    'ko': '장애물 알림',
    'th': 'การแจ้งเตือนสิ่งกีดขวาง',
    'pt': 'Alertas de Obstáculos',
    'fr': 'Alertes d\'obstacles',
  });

  String get trafficLightAlerts => _translate({
    'es': 'Alertas de Semáforo',
    'en': 'Traffic Light Alerts',
    'zh': '交通灯警报',
    'de': 'Ampelwarnungen',
    'ja': '信号機アラート',
    'ko': '신호등 알림',
    'th': 'การแจ้งเตือนไฟจราจร',
    'pt': 'Alertas de Semáforo',
    'fr': 'Alertes de feux',
  });

  // Bluetooth
  String get bluetooth => 'Bluetooth';

  String get connected => _translate({
    'es': 'Conectado',
    'en': 'Connected',
    'zh': '已连接',
    'de': 'Verbunden',
    'ja': '接続済み',
    'ko': '연결됨',
    'th': 'เชื่อมต่อแล้ว',
    'pt': 'Conectado',
    'fr': 'Connecté',
  });

  String get disconnected => _translate({
    'es': 'Desconectado',
    'en': 'Disconnected',
    'zh': '未连接',
    'de': 'Getrennt',
    'ja': '切断',
    'ko': '연결 해제됨',
    'th': 'ตัดการเชื่อมต่อ',
    'pt': 'Desconectado',
    'fr': 'Déconnecté',
  });

  String get searching => _translate({
    'es': 'Buscando...',
    'en': 'Searching...',
    'zh': '搜索中...',
    'de': 'Suchen...',
    'ja': '検索中...',
    'ko': '검색 중...',
    'th': 'กำลังค้นหา...',
    'pt': 'Procurando...',
    'fr': 'Recherche...',
  });

  // Mensajes
  String get successfullyUpdated => _translate({
    'es': 'Actualizado exitosamente',
    'en': 'Successfully updated',
    'zh': '更新成功',
    'de': 'Erfolgreich aktualisiert',
    'ja': '正常に更新されました',
    'ko': '성공적으로 업데이트됨',
    'th': 'อัปเดตสำเร็จ',
    'pt': 'Atualizado com sucesso',
    'fr': 'Mis à jour avec succès',
  });

  String get error => _translate({
    'es': 'Error',
    'en': 'Error',
    'zh': '错误',
    'de': 'Fehler',
    'ja': 'エラー',
    'ko': '오류',
    'th': 'ข้อผิดพลาด',
    'pt': 'Erro',
    'fr': 'Erreur',
  });

  String get areYouSure => _translate({
    'es': '¿Estás seguro/a?',
    'en': 'Are you sure?',
    'zh': '你确定吗？',
    'de': 'Sind Sie sicher?',
    'ja': '本当によろしいですか？',
    'ko': '확실합니까?',
    'th': 'คุณแน่ใจหรือไม่?',
    'pt': 'Tem certeza?',
    'fr': 'Êtes-vous sûr?',
  });

  // Recuperar contraseña
  String get recoverPassword => _translate({
    'es': 'Recuperar Contraseña',
    'en': 'Recover Password',
    'zh': '恢复密码',
    'de': 'Passwort wiederherstellen',
    'ja': 'パスワードを回復',
    'ko': '비밀번호 복구',
    'th': 'กู้คืนรหัสผ่าน',
    'pt': 'Recuperar Senha',
    'fr': 'Récupérer le mot de passe',
  });

  String get resetPassword => _translate({
    'es': 'Reestablecer contraseña',
    'en': 'Reset password',
    'zh': '重置密码',
    'de': 'Passwort zurücksetzen',
    'ja': 'パスワードをリセット',
    'ko': '비밀번호 재설정',
    'th': 'รีเซ็ตรหัสผ่าน',
    'pt': 'Redefinir senha',
    'fr': 'Réinitialiser le mot de passe',
  });

  String get sendEmail => _translate({
    'es': 'Enviar Correo',
    'en': 'Send Email',
    'zh': '发送邮件',
    'de': 'E-Mail senden',
    'ja': 'メールを送信',
    'ko': '이메일 보내기',
    'th': 'ส่งอีเมล',
    'pt': 'Enviar E-mail',
    'fr': 'Envoyer un e-mail',
  });

  String get emailSent => _translate({
    'es': 'Correo Enviado',
    'en': 'Email Sent',
    'zh': '邮件已发送',
    'de': 'E-Mail gesendet',
    'ja': 'メール送信済み',
    'ko': '이메일 전송됨',
    'th': 'ส่งอีเมลแล้ว',
    'pt': 'E-mail Enviado',
    'fr': 'E-mail envoyé',
  });
}
