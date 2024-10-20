// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Chart, { registerables } from "chart.js/auto";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Form upates on the Batch form
const orderNumberHandler = () => {
  const radio = document.querySelector('[name="batch[batch_type]"][value="order"]');
  const input = document.querySelector('[name="batch[order_number]');

  if (!input) return;

  if (radio?.checked) {
    input.disabled = false;
    input.classList.add("input-primary")
  } else {
    input.disabled = true;
    input.classList.remove("input-primary")
  }
}

orderNumberHandler();

document.addEventListener('change', (event) => {
  if (event.target.closest('[name="batch[batch_type]"')) {
    orderNumberHandler();
  }
});

// Dashboard charts
const canvas = document.querySelector('canvas#chart');
const dataString = canvas?.dataset.points;
if (dataString) {
  const data = JSON.parse(dataString)
  const chartData = {
    datasets: [
      {
        label: 'Total',
        data,
        borderColor: 'rgb(148, 69, 150)',
        backgroundColor: 'rgba(148, 69, 150, 0.6)',
        parsing: {
          yAxisKey: 'username',
          xAxisKey: 'total'
        }
      },
      {
        label: 'Numbers',
        data,
        borderColor: 'rgb(50, 100, 255)',
        backgroundColor: 'rgba(50, 100, 255, 0.6)',
        parsing: {
          yAxisKey: 'username',
          xAxisKey: 'numbers'
        }
      },
      {
        label: 'Names',
        data,
        borderColor: 'rgb(255, 50, 50)',
        backgroundColor: 'rgba(255, 50, 50, 0.6)',
        parsing: {
          yAxisKey: 'username',
          xAxisKey: 'names'
        }
      },
    ]
  };

  const chartConfig = {
    type: 'bar',
    data: chartData,
    options: {
      indexAxis: 'y',
      elements: {
        bar: {
          grouped: true,
          borderWidth: 0,
        }
      },
      responsive: true,
      plugins: {
        legend: {
          position: 'right',
        },
        title: {
          display: true,
          text: 'Button production - today'
        }
      }
    }
  };

  new Chart(document.getElementById('chart'), chartConfig);
}
