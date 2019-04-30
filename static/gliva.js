function deleteWork(workId) {
  fetch(`/admin/work/${workId}`, { method: "DELETE" })
    .then(() => location.reload());
}
