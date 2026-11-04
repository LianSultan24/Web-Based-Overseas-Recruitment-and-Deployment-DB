-- Overseas Employment Management System (email-only notifications)
-- Target: MySQL 8 / MariaDB (InnoDB, utf8mb4). 52 tables.

CREATE DATABASE IF NOT EXISTS oems CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oems;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE roles (
  role_id INT NOT NULL AUTO_INCREMENT,
  role_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (role_id),
  CONSTRAINT uq_roles_name UNIQUE (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
  user_id INT NOT NULL AUTO_INCREMENT,
  role_id INT NOT NULL,
  username VARCHAR(50) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  last_login DATETIME NULL,
  PRIMARY KEY (user_id),
  CONSTRAINT uq_users_username UNIQUE (username),
  CONSTRAINT uq_users_email UNIQUE (email),
  CONSTRAINT fk_users_role_id FOREIGN KEY (role_id) REFERENCES roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE staff (
  staff_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  position_title VARCHAR(100) NULL,
  contact_no VARCHAR(20) NULL,
  PRIMARY KEY (staff_id),
  CONSTRAINT uq_staff_user_id UNIQUE (user_id),
  CONSTRAINT fk_staff_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE applicants (
  applicant_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  registered_by INT NOT NULL,
  applicant_no VARCHAR(30) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  middle_name VARCHAR(50) NULL,
  last_name VARCHAR(50) NOT NULL,
  suffix VARCHAR(10) NULL,
  birthdate DATE NULL,
  sex VARCHAR(10) NULL,
  civil_status VARCHAR(20) NULL,
  nationality VARCHAR(50) NULL,
  mobile_no VARCHAR(20) NULL,
  email VARCHAR(100) NOT NULL,
  date_registered DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (applicant_id),
  CONSTRAINT uq_applicants_user_id UNIQUE (user_id),
  CONSTRAINT uq_applicants_applicant_no UNIQUE (applicant_no),
  CONSTRAINT fk_applicants_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_applicants_registered_by FOREIGN KEY (registered_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE provinces (
  province_id INT NOT NULL AUTO_INCREMENT,
  province_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (province_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cities (
  city_id INT NOT NULL AUTO_INCREMENT,
  province_id INT NOT NULL,
  city_name VARCHAR(100) NOT NULL,
  zip_code VARCHAR(10) NULL,
  PRIMARY KEY (city_id),
  CONSTRAINT fk_cities_province_id FOREIGN KEY (province_id) REFERENCES provinces(province_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE applicant_addresses (
  address_id INT NOT NULL AUTO_INCREMENT,
  applicant_id INT NOT NULL,
  city_id INT NOT NULL,
  address_type VARCHAR(30) NULL,
  street VARCHAR(150) NULL,
  barangay VARCHAR(100) NULL,
  PRIMARY KEY (address_id),
  CONSTRAINT fk_applicant_addresses_applicant_id FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_applicant_addresses_city_id FOREIGN KEY (city_id) REFERENCES cities(city_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE applicant_passports (
  passport_id INT NOT NULL AUTO_INCREMENT,
  applicant_id INT NOT NULL,
  passport_no VARCHAR(20) NULL,
  issue_date DATE NULL,
  expiry_date DATE NULL,
  place_of_issue VARCHAR(100) NULL,
  PRIMARY KEY (passport_id),
  CONSTRAINT uq_applicant_passports_passport_no UNIQUE (passport_no),
  CONSTRAINT fk_applicant_passports_applicant_id FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE emergency_contacts (
  contact_id INT NOT NULL AUTO_INCREMENT,
  applicant_id INT NOT NULL,
  contact_name VARCHAR(100) NULL,
  relationship VARCHAR(50) NULL,
  contact_no VARCHAR(20) NULL,
  address VARCHAR(255) NULL,
  PRIMARY KEY (contact_id),
  CONSTRAINT fk_emergency_contacts_applicant_id FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE interview_results (
  result_id INT NOT NULL AUTO_INCREMENT,
  result_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (result_id),
  CONSTRAINT uq_interview_results_name UNIQUE (result_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE interviews (
  interview_id INT NOT NULL AUTO_INCREMENT,
  applicant_id INT NOT NULL,
  interviewer_id INT NOT NULL,
  result_id INT NULL,
  interview_date DATE NULL,
  remarks TEXT NULL,
  PRIMARY KEY (interview_id),
  CONSTRAINT fk_interviews_applicant_id FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_interviews_interviewer_id FOREIGN KEY (interviewer_id) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_interviews_result_id FOREIGN KEY (result_id) REFERENCES interview_results(result_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE countries (
  country_id INT NOT NULL AUTO_INCREMENT,
  country_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employers (
  employer_id INT NOT NULL AUTO_INCREMENT,
  employer_name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NULL,
  contact_person VARCHAR(100) NULL,
  contact_no VARCHAR(20) NULL,
  email VARCHAR(100) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (employer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE job_categories (
  category_id INT NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE job_orders (
  job_order_id INT NOT NULL AUTO_INCREMENT,
  category_id INT NOT NULL,
  employer_id INT NOT NULL,
  country_id INT NOT NULL,
  created_by INT NOT NULL,
  job_order_no VARCHAR(30) NOT NULL,
  vacancies INT NULL,
  salary DECIMAL(12,2) NULL,
  currency CHAR(3) NULL,
  contract_duration VARCHAR(50) NULL,
  date_posted DATE NULL,
  deadline DATE NULL,
  is_open TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (job_order_id),
  CONSTRAINT uq_job_orders_job_order_no UNIQUE (job_order_no),
  CONSTRAINT fk_job_orders_category_id FOREIGN KEY (category_id) REFERENCES job_categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_orders_employer_id FOREIGN KEY (employer_id) REFERENCES employers(employer_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_orders_country_id FOREIGN KEY (country_id) REFERENCES countries(country_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_orders_created_by FOREIGN KEY (created_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE requirements (
  requirement_id INT NOT NULL AUTO_INCREMENT,
  requirement_name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  instructions TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (requirement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE requirement_stages (
  stage_id INT NOT NULL AUTO_INCREMENT,
  stage_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (stage_id),
  CONSTRAINT uq_requirement_stages_name UNIQUE (stage_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE copy_types (
  copy_type_id INT NOT NULL AUTO_INCREMENT,
  copy_type_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (copy_type_id),
  CONSTRAINT uq_copy_types_name UNIQUE (copy_type_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE job_order_requirements (
  jo_requirement_id INT NOT NULL AUTO_INCREMENT,
  job_order_id INT NOT NULL,
  requirement_id INT NOT NULL,
  stage_id INT NOT NULL,
  copy_type_id INT NOT NULL,
  is_mandatory TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (jo_requirement_id),
  CONSTRAINT uq_jor_job_req UNIQUE (job_order_id, requirement_id),
  CONSTRAINT fk_job_order_requirements_job_order_id FOREIGN KEY (job_order_id) REFERENCES job_orders(job_order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_order_requirements_requirement_id FOREIGN KEY (requirement_id) REFERENCES requirements(requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_order_requirements_stage_id FOREIGN KEY (stage_id) REFERENCES requirement_stages(stage_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_order_requirements_copy_type_id FOREIGN KEY (copy_type_id) REFERENCES copy_types(copy_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE checklist_items (
  checklist_item_id INT NOT NULL AUTO_INCREMENT,
  requirement_id INT NOT NULL,
  item_description TEXT NULL,
  validation_criteria TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (checklist_item_id),
  CONSTRAINT fk_checklist_items_requirement_id FOREIGN KEY (requirement_id) REFERENCES requirements(requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE application_statuses (
  status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (status_id),
  CONSTRAINT uq_application_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE applications (
  application_id INT NOT NULL AUTO_INCREMENT,
  applicant_id INT NOT NULL,
  job_order_id INT NOT NULL,
  status_id INT NOT NULL,
  assigned_by INT NOT NULL,
  application_date DATE NULL,
  remarks TEXT NULL,
  PRIMARY KEY (application_id),
  CONSTRAINT uq_applications_applicant_job UNIQUE (applicant_id, job_order_id),
  CONSTRAINT fk_applications_applicant_id FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_applications_job_order_id FOREIGN KEY (job_order_id) REFERENCES job_orders(job_order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_applications_status_id FOREIGN KEY (status_id) REFERENCES application_statuses(status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_applications_assigned_by FOREIGN KEY (assigned_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE application_status_history (
  history_id INT NOT NULL AUTO_INCREMENT,
  application_id INT NOT NULL,
  status_id INT NOT NULL,
  changed_by INT NOT NULL,
  changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  remarks TEXT NULL,
  PRIMARY KEY (history_id),
  CONSTRAINT fk_application_status_history_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_status_history_status_id FOREIGN KEY (status_id) REFERENCES application_statuses(status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_status_history_changed_by FOREIGN KEY (changed_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE submission_statuses (
  submission_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (submission_status_id),
  CONSTRAINT uq_submission_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE verification_statuses (
  verification_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (verification_status_id),
  CONSTRAINT uq_verification_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE application_requirements (
  app_requirement_id INT NOT NULL AUTO_INCREMENT,
  application_id INT NOT NULL,
  requirement_id INT NOT NULL,
  stage_id INT NOT NULL,
  copy_type_id INT NOT NULL,
  hard_copy_status_id INT NOT NULL,
  soft_copy_status_id INT NOT NULL,
  verification_status_id INT NOT NULL,
  is_mandatory TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (app_requirement_id),
  CONSTRAINT uq_appreq_app_req UNIQUE (application_id, requirement_id),
  CONSTRAINT fk_application_requirements_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_requirement_id FOREIGN KEY (requirement_id) REFERENCES requirements(requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_stage_id FOREIGN KEY (stage_id) REFERENCES requirement_stages(stage_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_copy_type_id FOREIGN KEY (copy_type_id) REFERENCES copy_types(copy_type_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_hard_copy_status_id FOREIGN KEY (hard_copy_status_id) REFERENCES submission_statuses(submission_status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_soft_copy_status_id FOREIGN KEY (soft_copy_status_id) REFERENCES submission_statuses(submission_status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_application_requirements_verification_status_id FOREIGN KEY (verification_status_id) REFERENCES verification_statuses(verification_status_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE hard_copy_receipts (
  receipt_id INT NOT NULL AUTO_INCREMENT,
  app_requirement_id INT NOT NULL,
  received_by INT NOT NULL,
  received_date DATE NULL,
  remarks TEXT NULL,
  PRIMARY KEY (receipt_id),
  CONSTRAINT fk_hard_copy_receipts_app_requirement_id FOREIGN KEY (app_requirement_id) REFERENCES application_requirements(app_requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_hard_copy_receipts_received_by FOREIGN KEY (received_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE submission_methods (
  method_id INT NOT NULL AUTO_INCREMENT,
  method_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (method_id),
  CONSTRAINT uq_submission_methods_name UNIQUE (method_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ocr_statuses (
  ocr_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (ocr_status_id),
  CONSTRAINT uq_ocr_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE document_files (
  file_id INT NOT NULL AUTO_INCREMENT,
  app_requirement_id INT NOT NULL,
  method_id INT NOT NULL,
  uploaded_by INT NOT NULL,
  ocr_status_id INT NULL,
  file_name VARCHAR(255) NULL,
  file_path VARCHAR(500) NULL,
  file_type VARCHAR(50) NULL,
  version_no INT NOT NULL DEFAULT 1,
  is_current TINYINT(1) NOT NULL DEFAULT 1,
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (file_id),
  CONSTRAINT uq_docfile_ver UNIQUE (app_requirement_id, version_no),
  CONSTRAINT fk_document_files_app_requirement_id FOREIGN KEY (app_requirement_id) REFERENCES application_requirements(app_requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_files_method_id FOREIGN KEY (method_id) REFERENCES submission_methods(method_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_files_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_files_ocr_status_id FOREIGN KEY (ocr_status_id) REFERENCES ocr_statuses(ocr_status_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ocr_results (
  ocr_id INT NOT NULL AUTO_INCREMENT,
  file_id INT NOT NULL,
  initiated_by INT NULL,
  raw_text LONGTEXT NULL,
  avg_confidence DECIMAL(5,2) NULL,
  processed_at DATETIME NULL,
  PRIMARY KEY (ocr_id),
  CONSTRAINT fk_ocr_results_file_id FOREIGN KEY (file_id) REFERENCES document_files(file_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ocr_results_initiated_by FOREIGN KEY (initiated_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ocr_extracted_fields (
  field_id INT NOT NULL AUTO_INCREMENT,
  ocr_id INT NOT NULL,
  field_name VARCHAR(100) NULL,
  extracted_value TEXT NULL,
  confidence_score DECIMAL(5,2) NULL,
  matches_record TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (field_id),
  CONSTRAINT fk_ocr_extracted_fields_ocr_id FOREIGN KEY (ocr_id) REFERENCES ocr_results(ocr_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE document_verifications (
  verification_id INT NOT NULL AUTO_INCREMENT,
  app_requirement_id INT NOT NULL,
  file_id INT NULL,
  verification_status_id INT NOT NULL,
  verified_by INT NULL,
  verified_at DATETIME NULL,
  remarks TEXT NULL,
  PRIMARY KEY (verification_id),
  CONSTRAINT fk_document_verifications_app_requirement_id FOREIGN KEY (app_requirement_id) REFERENCES application_requirements(app_requirement_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_verifications_file_id FOREIGN KEY (file_id) REFERENCES document_files(file_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_verifications_verification_status_id FOREIGN KEY (verification_status_id) REFERENCES verification_statuses(verification_status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_document_verifications_verified_by FOREIGN KEY (verified_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE verification_checklist_results (
  result_id INT NOT NULL AUTO_INCREMENT,
  verification_id INT NOT NULL,
  checklist_item_id INT NOT NULL,
  is_passed TINYINT(1) NOT NULL DEFAULT 0,
  remarks TEXT NULL,
  PRIMARY KEY (result_id),
  CONSTRAINT fk_verification_checklist_results_verification_id FOREIGN KEY (verification_id) REFERENCES document_verifications(verification_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_verification_checklist_results_checklist_item_id FOREIGN KEY (checklist_item_id) REFERENCES checklist_items(checklist_item_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clinics (
  clinic_id INT NOT NULL AUTO_INCREMENT,
  clinic_name VARCHAR(100) NOT NULL,
  address VARCHAR(255) NULL,
  contact_no VARCHAR(20) NULL,
  accreditation_no VARCHAR(50) NULL,
  accreditation_expiry DATE NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (clinic_id),
  CONSTRAINT uq_clinics_accreditation_no UNIQUE (accreditation_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE medical_exam_types (
  exam_type_id INT NOT NULL AUTO_INCREMENT,
  exam_name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (exam_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE job_order_exam_types (
  job_order_id INT NOT NULL,
  exam_type_id INT NOT NULL,
  PRIMARY KEY (job_order_id, exam_type_id),
  CONSTRAINT fk_job_order_exam_types_job_order_id FOREIGN KEY (job_order_id) REFERENCES job_orders(job_order_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_job_order_exam_types_exam_type_id FOREIGN KEY (exam_type_id) REFERENCES medical_exam_types(exam_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE medical_statuses (
  medical_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (medical_status_id),
  CONSTRAINT uq_medical_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE medical_examinations (
  medical_id INT NOT NULL AUTO_INCREMENT,
  application_id INT NOT NULL,
  clinic_id INT NOT NULL,
  medical_status_id INT NOT NULL,
  scheduled_by INT NOT NULL,
  recorded_by INT NULL,
  attempt_no INT NOT NULL DEFAULT 1,
  exam_date DATE NULL,
  exam_time TIME NULL,
  repeat_reason TEXT NULL,
  result_received_date DATE NULL,
  remarks TEXT NULL,
  PRIMARY KEY (medical_id),
  CONSTRAINT uq_medex_app_attempt UNIQUE (application_id, attempt_no),
  CONSTRAINT fk_medical_examinations_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_examinations_clinic_id FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_examinations_medical_status_id FOREIGN KEY (medical_status_id) REFERENCES medical_statuses(medical_status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_examinations_scheduled_by FOREIGN KEY (scheduled_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_examinations_recorded_by FOREIGN KEY (recorded_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE medical_exam_results (
  result_id INT NOT NULL AUTO_INCREMENT,
  medical_id INT NOT NULL,
  exam_type_id INT NOT NULL,
  result_value VARCHAR(255) NULL,
  result_flag VARCHAR(30) NULL,
  remarks TEXT NULL,
  PRIMARY KEY (result_id),
  CONSTRAINT fk_medical_exam_results_medical_id FOREIGN KEY (medical_id) REFERENCES medical_examinations(medical_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_medical_exam_results_exam_type_id FOREIGN KEY (exam_type_id) REFERENCES medical_exam_types(exam_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE assessment_decisions (
  decision_id INT NOT NULL AUTO_INCREMENT,
  decision_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (decision_id),
  CONSTRAINT uq_assessment_decisions_name UNIQUE (decision_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE final_assessments (
  assessment_id INT NOT NULL AUTO_INCREMENT,
  application_id INT NOT NULL,
  decision_id INT NOT NULL,
  assessed_by INT NOT NULL,
  approved_by INT NULL,
  assessment_date DATE NULL,
  remarks TEXT NULL,
  PRIMARY KEY (assessment_id),
  CONSTRAINT fk_final_assessments_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_final_assessments_decision_id FOREIGN KEY (decision_id) REFERENCES assessment_decisions(decision_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_final_assessments_assessed_by FOREIGN KEY (assessed_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_final_assessments_approved_by FOREIGN KEY (approved_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE deployment_readiness (
  readiness_id INT NOT NULL AUTO_INCREMENT,
  application_id INT NOT NULL,
  assessed_by INT NOT NULL,
  is_ready TINYINT(1) NOT NULL DEFAULT 0,
  assessed_at DATETIME NULL,
  remarks TEXT NULL,
  PRIMARY KEY (readiness_id),
  CONSTRAINT fk_deployment_readiness_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_deployment_readiness_assessed_by FOREIGN KEY (assessed_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dispatch_batches (
  batch_id INT NOT NULL AUTO_INCREMENT,
  created_by INT NOT NULL,
  batch_name VARCHAR(100) NOT NULL,
  dispatch_date DATE NULL,
  departure_time TIME NULL,
  meeting_point VARCHAR(255) NULL,
  instructions TEXT NULL,
  PRIMARY KEY (batch_id),
  CONSTRAINT fk_dispatch_batches_created_by FOREIGN KEY (created_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dispatch_statuses (
  dispatch_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (dispatch_status_id),
  CONSTRAINT uq_dispatch_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dispatch_schedules (
  dispatch_id INT NOT NULL AUTO_INCREMENT,
  batch_id INT NOT NULL,
  application_id INT NOT NULL,
  dispatch_status_id INT NOT NULL,
  dispatched_by INT NOT NULL,
  arrival_confirmed_by INT NULL,
  travel_details TEXT NULL,
  dispatched_at DATETIME NULL,
  arrival_confirmed_at DATETIME NULL,
  remarks TEXT NULL,
  PRIMARY KEY (dispatch_id),
  CONSTRAINT fk_dispatch_schedules_batch_id FOREIGN KEY (batch_id) REFERENCES dispatch_batches(batch_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dispatch_schedules_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dispatch_schedules_dispatch_status_id FOREIGN KEY (dispatch_status_id) REFERENCES dispatch_statuses(dispatch_status_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dispatch_schedules_dispatched_by FOREIGN KEY (dispatched_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dispatch_schedules_arrival_confirmed_by FOREIGN KEY (arrival_confirmed_by) REFERENCES staff(staff_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notification_events (
  event_id INT NOT NULL AUTO_INCREMENT,
  event_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (event_id),
  CONSTRAINT uq_notification_events_name UNIQUE (event_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notification_templates (
  template_id INT NOT NULL AUTO_INCREMENT,
  event_id INT NOT NULL,
  subject VARCHAR(200) NULL,
  message_body TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (template_id),
  CONSTRAINT fk_notification_templates_event_id FOREIGN KEY (event_id) REFERENCES notification_events(event_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE delivery_statuses (
  delivery_status_id INT NOT NULL AUTO_INCREMENT,
  status_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (delivery_status_id),
  CONSTRAINT uq_delivery_statuses_name UNIQUE (status_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notifications (
  notification_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  application_id INT NULL,
  template_id INT NOT NULL,
  sent_by INT NULL,
  delivery_status_id INT NOT NULL,
  message TEXT NULL,
  sent_at DATETIME NULL,
  delivered_at DATETIME NULL,
  failure_reason TEXT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (notification_id),
  CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notifications_application_id FOREIGN KEY (application_id) REFERENCES applications(application_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notifications_template_id FOREIGN KEY (template_id) REFERENCES notification_templates(template_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notifications_sent_by FOREIGN KEY (sent_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_notifications_delivery_status_id FOREIGN KEY (delivery_status_id) REFERENCES delivery_statuses(delivery_status_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE system_settings (
  setting_id INT NOT NULL AUTO_INCREMENT,
  updated_by INT NOT NULL,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (setting_id),
  CONSTRAINT uq_system_settings_setting_key UNIQUE (setting_key),
  CONSTRAINT fk_system_settings_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE activity_logs (
  log_id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  action VARCHAR(100) NULL,
  module VARCHAR(100) NULL,
  table_name VARCHAR(100) NULL,
  record_id INT NULL,
  ip_address VARCHAR(45) NULL,
  logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  CONSTRAINT fk_activity_logs_user_id FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- Sample lookup data (edit as needed)
INSERT INTO roles (role_name) VALUES ('Admin'),('Staff'),('Applicant');
INSERT INTO interview_results (result_name) VALUES ('Passed'),('Failed'),('For Re-interview');
INSERT INTO application_statuses (status_name) VALUES ('Pending'),('Under Review'),('For Interview'),('For Medical'),('Approved'),('Deployed'),('Rejected');
INSERT INTO requirement_stages (stage_name) VALUES ('Application'),('Pre-Medical'),('Pre-Deployment');
INSERT INTO copy_types (copy_type_name) VALUES ('Hard Copy'),('Soft Copy'),('Both');
INSERT INTO submission_statuses (status_name) VALUES ('Not Submitted'),('Submitted'),('Not Required');
INSERT INTO verification_statuses (status_name) VALUES ('Pending'),('Verified'),('Rejected'),('For Resubmission');
INSERT INTO ocr_statuses (status_name) VALUES ('Pending'),('Processing'),('Completed'),('Failed');
INSERT INTO submission_methods (method_name) VALUES ('Online Upload'),('Walk-in'),('Courier');
INSERT INTO medical_statuses (status_name) VALUES ('Scheduled'),('Completed'),('Fit'),('Unfit'),('For Repeat');
INSERT INTO assessment_decisions (decision_name) VALUES ('Approved'),('Rejected'),('On Hold');
INSERT INTO dispatch_statuses (status_name) VALUES ('Scheduled'),('Dispatched'),('Arrived'),('Cancelled');
INSERT INTO notification_events (event_name) VALUES ('Application Received'),('Interview Scheduled'),('Document Verified'),('Document Rejected'),('Medical Scheduled'),('Medical Result'),('Assessment Result'),('Dispatch Schedule');
INSERT INTO delivery_statuses (status_name) VALUES ('Pending'),('Sent'),('Delivered'),('Failed');
