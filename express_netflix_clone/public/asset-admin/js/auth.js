// function checkAuth() {
//     fetch('http://localhost:5000/api/users/me', {
//       headers: { 'Content-Type': 'application/json' },
//       credentials: 'include'
//     })
//       .then(response => {
//         if (!response.ok) {
//           console.error(`Error checking auth: HTTP ${response.status}`);
//           Toastify({
//             text: 'Session expired, redirecting to login',
//             duration: 3000,
//             style: { background: 'red' }
//           }).showToast();
//           setTimeout(() => (window.location.href = '/login'), 3000);
//         }
//       })
//       .catch(error => {
//         console.error('Error checking auth:', error);
//         Toastify({
//           text: 'Error checking session, redirecting to login',
//           duration: 3000,
//           style: { background: 'red' }
//         }).showToast();
//         setTimeout(() => (window.location.href = '/login'), 3000);
//       });
//   }