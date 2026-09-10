pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  parameters {
    booleanParam(
      name: 'DEPLOY',
      defaultValue: true,
      description: 'Deploy ด้วย docker compose หลัง build สำเร็จ'
    )
    string(
      name: 'API_PORT',
      defaultValue: '3006',
      description: 'พอร์ตบน host ที่ map ไป container API (host:container → API_PORT:3006)'
    )
    string(
      name: 'CORS_ORIGIN',
      defaultValue: '*',
      description: 'Origin ของ frontend ที่อนุญาต (คั่นด้วย comma ได้ หรือ * )'
    )
    string(
      name: 'DATABASE_URL',
      defaultValue: '',
      description: 'Connection string ของ PostgreSQL (ถ้า password มี # ให้ใส่เป็น %23) — ถ้าว่างจะใช้ DB_*'
    )
    string(
      name: 'DB_HOST',
      defaultValue: '',
      description: 'ใช้เมื่อไม่ใส่ DATABASE_URL'
    )
    string(
      name: 'DB_PORT',
      defaultValue: '5432',
      description: 'พอร์ต Postgres'
    )
    string(
      name: 'DB_USER',
      defaultValue: 'postgres',
      description: 'user Postgres'
    )
    password(
      name: 'DB_PASS',
      defaultValue: '',
      description: 'รหัสผ่าน Postgres (ใช้เมื่อไม่พึ่ง DATABASE_URL หรือเป็นค่าสำรอง)'
    )
    string(
      name: 'DB_NAME',
      defaultValue: 'personal_website',
      description: 'ชื่อ database'
    )
    password(
      name: 'JWT_SECRET',
      defaultValue: '',
      description: 'JWT secret สำหรับเซ็น token (จำเป็นต้องใส่)'
    )
  }

  environment {
    COMPOSE_PROJECT_NAME = 'personal-website-api'
    IMAGE_NAME = 'personal-website-api'
    API_PORT = "${params.API_PORT}"
    PORT = '3006'
    CORS_ORIGIN = "${params.CORS_ORIGIN}"
    DATABASE_URL = "${params.DATABASE_URL}"
    DB_HOST = "${params.DB_HOST}"
    DB_PORT = "${params.DB_PORT}"
    DB_USER = "${params.DB_USER}"
    DB_PASS = "${params.DB_PASS}"
    DB_NAME = "${params.DB_NAME}"
    JWT_SECRET = "${params.JWT_SECRET}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate') {
      steps {
        sh '''
          set -e
          if [ -z "${JWT_SECRET}" ]; then
            echo "JWT_SECRET is required"
            exit 1
          fi

          has_url=0
          if [ -n "${DATABASE_URL}" ]; then
            has_url=1
          fi

          if [ "${has_url}" -eq 0 ]; then
            if [ -z "${DB_HOST}" ] || [ -z "${DB_PASS}" ]; then
              echo "Provide DATABASE_URL (encode # as %23) or set DB_HOST + DB_PASS"
              exit 1
            fi
          fi
        '''
      }
    }

    stage('Build image') {
      steps {
        sh '''
          set -e
          export API_PORT="${API_PORT}"
          export PORT="${PORT}"
          export CORS_ORIGIN="${CORS_ORIGIN}"
          export DATABASE_URL="${DATABASE_URL}"
          export DB_HOST="${DB_HOST}"
          export DB_PORT="${DB_PORT}"
          export DB_USER="${DB_USER}"
          export DB_PASS="${DB_PASS}"
          export DB_NAME="${DB_NAME}"
          export JWT_SECRET="${JWT_SECRET}"
          docker compose build api
        '''
      }
    }

    stage('Deploy') {
      when {
        expression { return params.DEPLOY == true }
      }
      steps {
        sh '''
          set -e
          export API_PORT="${API_PORT}"
          export PORT="${PORT}"
          export CORS_ORIGIN="${CORS_ORIGIN}"
          export DATABASE_URL="${DATABASE_URL}"
          export DB_HOST="${DB_HOST}"
          export DB_PORT="${DB_PORT}"
          export DB_USER="${DB_USER}"
          export DB_PASS="${DB_PASS}"
          export DB_NAME="${DB_NAME}"
          export JWT_SECRET="${JWT_SECRET}"
          docker compose up -d --remove-orphans api
        '''
      }
    }

    stage('Health check') {
      when {
        expression { return params.DEPLOY == true }
      }
      steps {
        sh '''
          set -e
          echo "Waiting for API on :${API_PORT}/personal-website/api/health ..."
          for i in $(seq 1 30); do
            code="$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${API_PORT}/personal-website/api/health" || true)"
            if echo "$code" | grep -Eq '^[123]'; then
              echo "API is healthy (HTTP $code)"
              exit 0
            fi
            if [ "$i" -eq 30 ]; then
              echo "API health check failed (HTTP $code)"
              docker compose ps || true
              docker compose logs --tail=80 api || true
              exit 1
            fi
            sleep 2
          done
        '''
      }
    }
  }

  post {
    success {
      echo "personal-website-api #${env.BUILD_NUMBER} succeeded → http://127.0.0.1:${params.API_PORT}/personal-website/api/health"
    }
    failure {
      echo "personal-website-api #${env.BUILD_NUMBER} failed"
      sh 'docker compose ps || true'
    }
  }
}
