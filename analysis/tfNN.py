import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import time

def main(params,label,f,title):
    # unpack parameters
    learning_rate = params[0]
    training_epochs = params[1]
    batch_size = params[2]
    n_classes = params[3]
    n_nodes = params[4]
    n_layers = len(n_nodes)

    # Construct model based on the number of layers
    pred,x,y = create_layers(n_layers,n_nodes,n_classes)

    # Define loss and optimizer
    cost = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits_v2(logits=pred, labels=y))
    optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(cost)

    # Initializing the variables
    init = tf.global_variables_initializer()

    # read in data
    train_features, train_labels, test_features, test_labels,test_labels_vec,labels = preprocess(f,label,n_classes)

    # start a timer
    start = time.time()

    # Launch the graph
    with tf.Session() as sess:
        sess.run(init)

        # Training cycle
        for epoch in range(training_epochs):
            avg_cost = 0.
            total_batch = int(train_features.shape[0] / batch_size)
            # Loop over all batches
            for i in range(total_batch):
                batch_x, batch_y = train_features[i * batch_size: (i + 1) * batch_size], train_labels[i * batch_size: (i + 1) * batch_size]
                # Run optimization op (backprop) and cost op (to get loss value)
                _, c = sess.run([optimizer, cost], feed_dict={x: batch_x, y: batch_y})
                # Compute average loss
                avg_cost += c / total_batch

        # end timer
        end = time.time()

        print("Optimization Finished!")
        correct_prediction = tf.equal(tf.argmax(pred, 1), tf.argmax(y, 1))

        # get predictions from model
        prediction = tf.argmax(pred,1)
        test_pred = prediction.eval({x : test_features})

        accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
        print("\nFor " + str(n_layers) + " Hidden Layers:\n")
        print("Time Elapsed: " + str(end-start))
        print("Accuracy:", accuracy.eval({x: test_features, y: test_labels}))
        print("\n")
        plot_confMat(test_labels_vec,test_pred,labels,title)

def create_layers(n_layers,n_nodes,n_classes):
    n_hidden_1 = n_nodes[0]  # 1st layer number of features
    if n_layers > 1:
        n_hidden_2 = n_nodes[1] # 2nd layer number of features
    if n_layers > 2:
        n_hidden_3 = n_nodes[2]  # 3rd layer number of features
    if n_layers > 3:
        n_hidden_4 = n_nodes[3]  # 3rd layer number of features

    n_input = 399

    # tf Graph input
    x = tf.placeholder("float", [None, n_input])
    y = tf.placeholder("float", [None, n_classes])

    if n_layers == 1:
        # initialize layer weights and biases
        weights = {
            'h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
            'out': tf.Variable(tf.random_normal([n_hidden_1, n_classes]))
        }
        biases = {
            'b1': tf.Variable(tf.random_normal([n_hidden_1])),
            'out': tf.Variable(tf.random_normal([n_classes]))
        }

        # Hidden layer with RELU activation
        layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
        layer_1 = tf.nn.relu(layer_1)
        # Output layer with linear activation
        out_layer = tf.matmul(layer_1, weights['out']) + biases['out']

    elif n_layers ==2:
        # initialize layer weights and biases
        weights = {
            'h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
            'h2': tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2])),
            'out': tf.Variable(tf.random_normal([n_hidden_2, n_classes]))
        }
        biases = {
            'b1': tf.Variable(tf.random_normal([n_hidden_1])),
            'b2': tf.Variable(tf.random_normal([n_hidden_2])),
            'out': tf.Variable(tf.random_normal([n_classes]))
        }

        # Hidden layer with RELU activation
        layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
        layer_1 = tf.nn.relu(layer_1)
        # Hidden layer with RELU activation
        layer_2 = tf.add(tf.matmul(layer_1, weights['h2']), biases['b2'])
        layer_2 = tf.nn.relu(layer_2)
        # Output layer with linear activation
        out_layer = tf.matmul(layer_2, weights['out']) + biases['out']

    elif n_layers == 3:
        # initialize layer weights and biases
        weights = {
            'h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
            'h2': tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2])),
            'h3': tf.Variable(tf.random_normal([n_hidden_2, n_hidden_3])),
            'out': tf.Variable(tf.random_normal([n_hidden_3, n_classes]))
        }
        biases = {
            'b1': tf.Variable(tf.random_normal([n_hidden_1])),
            'b2': tf.Variable(tf.random_normal([n_hidden_2])),
            'b3': tf.Variable(tf.random_normal([n_hidden_3])),
            'out': tf.Variable(tf.random_normal([n_classes]))
        }

        # Hidden layer with RELU activation
        layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
        layer_1 = tf.nn.relu(layer_1)
        # Hidden layer with RELU activation
        layer_2 = tf.add(tf.matmul(layer_1, weights['h2']), biases['b2'])
        layer_2 = tf.nn.relu(layer_2)
        # Hidden layer with RELU activation
        layer_3 = tf.add(tf.matmul(layer_2, weights['h3']), biases['b3'])
        layer_3 = tf.nn.relu(layer_3)
        # Output layer with linear activation
        out_layer = tf.matmul(layer_3, weights['out']) + biases['out']

    elif n_layers == 4:
        # initialize layer weights and biases
        weights = {
            'h1': tf.Variable(tf.random_normal([n_input, n_hidden_1])),
            'h2': tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2])),
            'h3': tf.Variable(tf.random_normal([n_hidden_2, n_hidden_3])),
            'h4': tf.Variable(tf.random_normal([n_hidden_3, n_hidden_4])),
            'out': tf.Variable(tf.random_normal([n_hidden_4, n_classes]))
        }
        biases = {
            'b1': tf.Variable(tf.random_normal([n_hidden_1])),
            'b2': tf.Variable(tf.random_normal([n_hidden_2])),
            'b3': tf.Variable(tf.random_normal([n_hidden_3])),
            'b4': tf.Variable(tf.random_normal([n_hidden_4])),
            'out': tf.Variable(tf.random_normal([n_classes]))
        }

        # Hidden layer with RELU activation
        layer_1 = tf.add(tf.matmul(x, weights['h1']), biases['b1'])
        layer_1 = tf.nn.relu(layer_1)
        # Hidden layer with RELU activation
        layer_2 = tf.add(tf.matmul(layer_1, weights['h2']), biases['b2'])
        layer_2 = tf.nn.relu(layer_2)
        # Hidden layer with RELU activation
        layer_3 = tf.add(tf.matmul(layer_2, weights['h3']), biases['b3'])
        layer_3 = tf.nn.relu(layer_3)
        # Hidden layer with RELU activation
        layer_4 = tf.add(tf.matmul(layer_3, weights['h4']), biases['b4'])
        layer_4 = tf.nn.relu(layer_4)
        # Output layer with linear activation
        out_layer = tf.matmul(layer_4, weights['out']) + biases['out']

    return out_layer,x,y

def preprocess(f,label,n_classes):

    df = pd.read_csv("../data/" + f,sep = ",")
    # split data
    train = df.sample(frac = 0.8,replace = False)
    test = df.drop(train.index)

    # form training and test data
    train_y = train[label]
    test_y = test[label]

    genres = np.unique(test_y)
    # create a dictionary to assign genre to number
    genreDict = {}
    for i in range(0,len(genres)):
        genreDict[genres[i]] = i
    # transform output to an list of integers
    numeric_test = [genreDict[t] for t in test_y]
    numeric_train = [genreDict[t] for t in train_y]



    #initialize label matrix
    test_y = np.zeros([len(numeric_test),n_classes])
    train_y = np.zeros([len(numeric_train),n_classes])

    for i in range(train_y.shape[0]):
        train_y[i,numeric_train[i]] = 1
    for i in range(test_y.shape[0]):
        test_y[i,numeric_test[i]] = 1

    train_x = train.drop(label,axis =1)
    test_x = test.drop(label,axis =1)

    # ensure that x data is double
    train_x = np.double(train_x)
    test_x = np.double(test_x)

    return train_x, train_y, test_x, test_y, numeric_test,genres

def plot_confMat(truth,predicted,labels,title):
    num_classes = len(np.unique(truth))
    # Get the confusion matrix using sklearn.
    cm = confusion_matrix(y_true=truth,
                          y_pred=predicted)

    # Print the confusion matrix as text.
    #print(cm)

    # Plot the confusion matrix as an image.
    plt.matshow(cm)

    # Make various adjustments to the plot.
    plt.colorbar()
    tick_marks = np.arange(num_classes)
    plt.xticks(tick_marks, labels,rotation = 90)
    plt.yticks(tick_marks, labels)
    plt.xlabel('Predicted')
    plt.ylabel('True')

    #plt.show()
    plt.savefig("../figs/NN/NNconfusionMatrix" + title, bbox_inches="tight")


if __name__ == "__main__":
    params1 = [0.0001,300,400,12,[400,400]]
    params2 = [0.0001,200,400,4,[400,400,400]]
    params3 = [0.0001,400,600,4,[400,400,400]]
    #main(params1,"group","UnderSampledUnscaled.csv","UndersampledUnscaledData")
    main(params1,"group","UnderSampled.csv","Undersampled Data")
    #main(params2,"group","ScaledUnderSampled.csv","Scaled Undersampled Data")
    #main(params3,"group","ReconstructedUnderSampled.csv","Reconsructed Undersampled Data")
