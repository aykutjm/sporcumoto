// PM2 Configuration - Her 2 dakikada auto-reply çalıştır
module.exports = {
  apps: [{
    name: 'auto-reply-cron',
    script: 'auto-reply-missed-calls.js',
    cron_restart: '*/2 * * * *',  // Her 2 dakikada
    watch: false,
    autorestart: false,  // Cron modunda otomatik restart kapalı
    env: {
      NODE_ENV: 'production'
    }
  }]
};
