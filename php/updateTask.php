<?php
include 'connection.php';

$id = $_POST['id'];
$is_completed = $_POST['is_completed']; // 0 or 1

$sql = "UPDATE tasks SET is_completed = $is_completed WHERE id = $id";

if ($con->query($sql) === TRUE) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false, "error" => $con->error));
}

$con->close();
?>
