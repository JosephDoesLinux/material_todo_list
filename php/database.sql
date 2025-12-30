-- CREATE DATABASE IF NOT EXISTS material_todo_list;
-- USE material_todo_list;

CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    details TEXT,
    is_completed TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data matching your Flutter app
INSERT INTO tasks (title, details, is_completed) VALUES
('Task 1', 'Details 1', 0),
('Task 2', 'Details 2', 1),
('Task 3', 'lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet lorem ipsum dolor sit amet ', 0);
