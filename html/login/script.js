const loginButton = document.getElementById('login');

loginButton.addEventListener('click', function() {
    const accountValue = document.getElementById('account').value;
    const passwordValue = document.getElementById('password').value;

    if (accountValue && passwordValue) {
        localStorage.setItem('account', accountValue);
        localStorage.setItem('password', passwordValue);

    var url = new URL('/login/login.py', window.location.origin);
    url.searchParams.append('account', accountValue);
    url.searchParams.append('password', passwordValue);

    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
            alert('Success: ' + data);
        })
        .catch((error) => {
            alert('Error: ' + error.message);
        });

        document.getElementById('p').textContent = 'Account Logged In: ' + localStorage.getItem('account');
    } else {
        document.getElementById('p').textContent = 'Please enter both account and password.';
    }
});


if (localStorage.getItem('account')) {
    document.getElementById('p').textContent = 'Account Logged In: ' + localStorage.getItem('account');
} else {
    document.getElementById('p').textContent = 'No Login';
}

