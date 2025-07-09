# 🚀 OpenShift Learning Series

This repository provides a structured and hands-on learning path to master **Red Hat OpenShift**, including real-world examples, setup guides, and troubleshooting documentation.

---

## 📂 Repository Structure

```
├── lessons/                 # Daily OpenShift lessons and hands-on labs
│   ├── day01/               # Introduction to OpenShift, architecture
│   │   ├── README.md        # Complete lesson content
│   │   ├── lab-scripts.sh   # Automated lab exercises
│   │   └── quick-reference.md # Essential commands & concepts
│   ├── day02/               # OpenShift CLI (oc), projects, users
│   └── ...
├── docs/                   # Setup instructions and issue resolution
│   ├── setup.md            # Prerequisites, installation steps
│   └── troubleshooting.md  # Common issues and fixes
└── README.md               # Project overview and navigation
```

---

## 📘 What You'll Learn

| Day | Topic                    | Key Concepts Covered                          | Status |
| --- | ------------------------ | --------------------------------------------- | ------ |
| 01  | Intro to OpenShift       | Architecture, Cluster Components              | ✅ Available |
| 02  | OpenShift CLI & Projects | `oc` commands, project creation, RBAC         | ✅ Available |
| 03  | Deploying Applications   | BuildConfigs, DeploymentConfigs, Routes       | ✅ Available |
| 04  | ConfigMaps & Secrets     | Application configuration, secrets management |
| 05  | Persistent Storage       | PVC, PV, dynamic provisioning                 |
| 06  | CI/CD Pipelines          | OpenShift Pipelines (Tekton), triggers        |
| 07  | Monitoring & Logging     | Prometheus, Grafana, Loki, EFK Stack          |
| 08  | Security & Policies      | SCC, Network Policies, RoleBindings           |
| 09  | Operators & Helm         | OperatorHub, Helm Charts                      |
| 10+ | Advanced Topics          | GitOps, Multi-tenancy, Cluster Upgrades       |

---

## 🧰 Requirements

* Access to an OpenShift Cluster (Local with CRC or Remote)
* OpenShift CLI (`oc`) installed
* Basic understanding of Kubernetes (preferred)

---

## 📄 Documentation

* [**docs/setup.md**](docs/setup.md) – Environment setup and prerequisites
* [**docs/troubleshooting.md**](docs/troubleshooting.md) – Common issues and fixes

---

## 🤝 Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/lesson-update`
3. Commit changes: `git commit -m "Add lesson X"`
4. Push: `git push origin feature/lesson-update`
5. Submit a PR

---

## 📌 Notes

This course is designed to be beginner-friendly and modular. You can pick up from any day depending on your existing knowledge.

Happy Learning! 🎓
