const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

async function runMigrations() {
  console.log('🚀 Database migrationlarni boshlash...\n');

  try {
    // Read all SQL files in migrations directory
    const migrationsDir = __dirname;
    const files = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort();

    for (const file of files) {
      console.log(`📄 ${file} ni bajarish...`);
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');

      await pool.query(sql);
      console.log(`✅ ${file} muvaffaqiyatli bajarildi\n`);
    }

    console.log('🎉 Barcha migrationlar muvaffaqiyatli bajarildi!');
    process.exit(0);

  } catch (error) {
    console.error('❌ Migration xatosi:', error.message);
    process.exit(1);
  }
}

runMigrations();
