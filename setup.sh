#!/bin/bash
# jccompany-gitops 레포 생성 + 설정 스크립트
# 실행 전: gh auth status 확인

set -e

REPO_NAME="jccompany-gitops"
OWNER="s1ns3nz0"

echo "=== 1. 레포 생성 (private) ==="
gh repo create ${OWNER}/${REPO_NAME} \
  --private \
  --description "JC Company GitOps repo — ArgoCD manages EKS deployments" \


echo "=== 2. 파일 복사 (이 스크립트 위치에서 실행) ==="
# /home/claude/jccompany-gitops/ 내용을 복사한 후 실행
# cp -r /home/claude/jccompany-gitops/. .

echo "=== 3. 초기 커밋 ==="
git add .
git commit -m "chore: initial gitops structure

- apps/payment-api: deployment, service, serviceaccount, kustomization
- .github/CODEOWNERS: @s1ns3nz0 승인 필수
- .github/workflows/validate.yml: manifest 검증 CI
- README 작성

Ref: NIST CM-3, SP 800-204D §5.1.1, SSDF PW.7.1"

git push origin main

echo "=== 4. 브랜치 보호 규칙 설정 ==="
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/${OWNER}/${REPO_NAME}/branches/main/protection \
  --field required_status_checks='{"strict":true,"contexts":["Validate K8s manifests"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":[],"teams":[],"apps":["gitops-bot"]}' \
  --field allow_force_pushes=false \
  --field allow_deletions=false

echo "=== 5. Secret scanning + Push Protection 활성화 ==="
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /repos/${OWNER}/${REPO_NAME} \
  --field security_and_analysis='{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}'

echo "=== 6. 확인 ==="
echo "레포 URL: https://github.com/${OWNER}/${REPO_NAME}"
echo "브랜치 보호 확인:"
gh api /repos/${OWNER}/${REPO_NAME}/branches/main/protection \
  --jq '{required_status_checks: .required_status_checks.contexts, restrictions: .restrictions}'

echo ""
echo "✅ Phase 1-A 완료"
echo "다음 단계: Phase 1-B — GitHub App 생성 (크로스 레포 토큰)"
