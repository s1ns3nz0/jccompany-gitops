# jccompany-gitops

> JC Company GitOps 레포지터리
> ArgoCD가 이 레포를 감시하여 EKS에 자동 배포합니다.

## 구조

```
apps/
└── payment-api/
    ├── deployment.yaml   # image digest 방식 (ArgoCD가 자동 업데이트)
    ├── service.yaml
    ├── serviceaccount.yaml
    └── kustomization.yaml
```

## 배포 흐름

```
jccompany-payment-api (GitHub Actions)
    → image build + ECR push
    → image digest 추출
    → 이 레포 deployment.yaml 업데이트 (GitHub App 토큰)
         ↓
    ArgoCD가 감지 → kustomize build → kubectl apply → EKS
```

## 브랜치 보호

- `main` 직접 push: GitHub App bot만 허용
- PR 머지: CODEOWNERS 승인 필수
- Required status check: `validate.yml` 통과 필수

## 관련 레포

| 레포 | 역할 |
|------|------|
| [jccompany-payment-api](https://github.com/s1ns3nz0/jccompany-payment-api) | 앱 소스 + CI/CD 파이프라인 |
| [jccompany-oscal-portfolio](https://github.com/s1ns3nz0/jccompany-oscal-portfolio) | OSCAL 컴플라이언스 문서 |

## 보안

- 이미지는 `tag` 대신 `sha256 digest`로 참조 (SP 800-204D §5.1.1)
- ArgoCD → 레포 연결: GitHub App 자격증명 (Sealed Secret)
- Secret scanning: GitHub Push Protection 활성화
