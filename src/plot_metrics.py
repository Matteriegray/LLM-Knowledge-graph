import matplotlib.pyplot as plt
from metrics_store import metrics_data

def plot_metrics():

    if len(metrics_data["queries"]) == 0:
        print("No data to plot yet.")
        return

    plt.figure()

    plt.plot(metrics_data["queries"], metrics_data["semantic"], marker='o', label='Semantic Similarity')
    plt.plot(metrics_data["queries"], metrics_data["factual"], marker='o', label='Factual Consistency')
    plt.plot(metrics_data["queries"], metrics_data["latency"], marker='o', label='Latency (s)')

    plt.xlabel("Query Number")
    plt.ylabel("Score / Time")
    plt.title("Live Performance Metrics")

    plt.legend()
    plt.show()