<?php
include 'connection.php';

$title = $_POST['title'];
$details = $_POST['details'];

$sql = "INSERT INTO tasks (title, details, is_completed) VALUES ('$title', '$details', 0)";

if ($con->query($sql) === TRUE) {
    echo json_encode(array("success" => true, "id" => $con->insert_id));
} else {
    echo json_encode(array("success" => false, "error" => $con->error));
}

$con->close();
?>
